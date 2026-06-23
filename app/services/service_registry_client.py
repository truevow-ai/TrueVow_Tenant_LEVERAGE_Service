"""
Service Registry Client for TrueVow DRAFT Service

Handles:
- Service registration with the Internal Ops registry (port 3006)
- Periodic heartbeats (every 5 minutes)
- Module registration for cross-service discovery
- Service and integration discovery

Version: 1.0
"""

import os
import asyncio
import logging
from typing import Optional, List, Dict, Any
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)

_httpx = None


def _get_httpx():
    global _httpx
    if _httpx is None:
        import httpx
        _httpx = httpx
    return _httpx


@dataclass
class ServiceConfig:
    """Service configuration for registration."""
    service_name: str
    service_type: str
    service_url: str
    port: int
    endpoints: List[Dict] = field(default_factory=list)
    agents: List[str] = field(default_factory=list)
    capabilities: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "service_name": self.service_name,
            "service_type": self.service_type,
            "service_url": self.service_url,
            "port": self.port,
            "endpoints": self.endpoints,
            "agents": self.agents,
            "capabilities": self.capabilities,
        }


class ServiceRegistryClient:
    """Client for Service Registry operations."""

    def __init__(self):
        self.registry_url = os.getenv("SERVICE_REGISTRY_URL", "http://localhost:3006")
        self.api_key = os.getenv("SERVICE_REGISTRY_API_KEY", "")
        self._client = None

    def _get_client(self):
        if self._client is None:
            httpx = _get_httpx()
            self._client = httpx.AsyncClient(
                base_url=self.registry_url,
                timeout=float(os.getenv("SERVICE_REGISTRATION_TIMEOUT_S", "10")),
            )
        return self._client

    def _headers(self) -> Dict[str, str]:
        h = {"Content-Type": "application/json"}
        if self.api_key:
            h["X-Registry-API-Key"] = self.api_key
        return h

    # ── SERVICE REGISTRATION ─────────────────────────────────────────────────

    async def register(self, config: ServiceConfig) -> Dict[str, Any]:
        """Register this service with the registry."""
        try:
            response = await self._get_client().post(
                "/api/v1/registry",
                json=config.to_dict(),
                headers=self._headers(),
            )
            response.raise_for_status()
            logger.info(f"Service registered: {config.service_name}")
            return response.json()
        except Exception as e:
            logger.error(f"Service registration failed: {e}")
            return {"success": False, "error": str(e)}

    async def heartbeat(self, service_name: str, status: str = "alive") -> Dict[str, Any]:
        """Send heartbeat to registry. Call every SERVICE_HEARTBEAT_INTERVAL_S seconds."""
        try:
            response = await self._get_client().post(
                "/api/v1/registry/heartbeat",
                json={"service_name": service_name, "status": status},
                headers=self._headers(),
            )
            return response.json()
        except Exception as e:
            logger.warning(f"Heartbeat failed: {e}")
            return {"success": False, "error": str(e)}

    async def get_service(self, service_name: str) -> Optional[Dict[str, Any]]:
        """Get a service by name for service discovery."""
        try:
            response = await self._get_client().get(f"/api/v1/registry/{service_name}")
            if response.status_code == 404:
                return None
            return response.json()
        except Exception as e:
            logger.error(f"Service lookup failed for '{service_name}': {e}")
            return None

    # ── MODULE REGISTRATION ──────────────────────────────────────────────────

    async def register_module(
        self,
        service_name: str,
        module_name: str,
        module_version: str = "1.0.0",
        description: str = None,
        endpoints: List[Dict] = None,
        events_published: List[Dict] = None,
        events_consumed: List[Dict] = None,
    ) -> Dict[str, Any]:
        """Register a module/feature for cross-service discovery."""
        try:
            response = await self._get_client().post(
                "/api/v1/registry/modules",
                json={
                    "service_name": service_name,
                    "module_name": module_name,
                    "module_version": module_version,
                    "description": description,
                    "endpoints": endpoints or [],
                    "events_published": events_published or [],
                    "events_consumed": events_consumed or [],
                },
                headers=self._headers(),
            )
            response.raise_for_status()
            logger.info(f"Module registered: {module_name}")
            return response.json()
        except Exception as e:
            logger.error(f"Module registration failed for '{module_name}': {e}")
            return {"success": False, "error": str(e)}

    # ── DISCOVERY ────────────────────────────────────────────────────────────

    async def get_modules(self, service_name: str) -> List[Dict[str, Any]]:
        """Get all registered modules for a service."""
        try:
            response = await self._get_client().get(
                f"/api/v1/registry/{service_name}/modules"
            )
            return response.json()
        except Exception as e:
            logger.error(f"Get modules failed: {e}")
            return []

    async def find_by_event(self, event_name: str) -> Dict[str, Any]:
        """Find services that publish or consume a given event."""
        try:
            response = await self._get_client().get(
                f"/api/v1/modules/by-event/{event_name}"
            )
            return response.json()
        except Exception as e:
            logger.error(f"Find by event failed: {e}")
            return {"publishers": [], "consumers": []}

    async def get_integrations(self, service_name: str) -> Dict[str, Any]:
        """Get integration partners for a service."""
        try:
            response = await self._get_client().get(
                f"/api/v1/integrations/{service_name}"
            )
            return response.json()
        except Exception as e:
            logger.error(f"Get integrations failed: {e}")
            return {"receives_from": [], "sends_to": []}

    async def register_integration(
        self,
        source_service: str,
        target_service: str,
        integration_type: str,
        purpose: str = None,
        event_triggers: List[str] = None,
    ) -> Dict[str, Any]:
        """Register a directed integration contract between two services."""
        try:
            response = await self._get_client().post(
                "/api/v1/integrations",
                json={
                    "source_service": source_service,
                    "target_service": target_service,
                    "integration_type": integration_type,
                    "purpose": purpose,
                    "event_triggers": event_triggers or [],
                },
                headers=self._headers(),
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Integration registration failed: {e}")
            return {"success": False, "error": str(e)}

    async def close(self):
        """Close the underlying HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None


# ── HEARTBEAT BACKGROUND TASK ─────────────────────────────────────────────────

class HeartbeatTask:
    """Sends periodic heartbeats to the service registry."""

    def __init__(self, service_name: str, interval_seconds: int = None):
        self.service_name = service_name
        self.interval_seconds = interval_seconds or int(
            os.getenv("SERVICE_HEARTBEAT_INTERVAL_S", "300")
        )
        self.client = ServiceRegistryClient()
        self._task: Optional[asyncio.Task] = None
        self._running = False

    async def _heartbeat_loop(self):
        while self._running:
            try:
                await self.client.heartbeat(self.service_name)
                logger.debug(f"Heartbeat sent: {self.service_name}")
            except Exception as e:
                logger.warning(f"Heartbeat loop error: {e}")
            await asyncio.sleep(self.interval_seconds)

    async def start(self):
        self._running = True
        self._task = asyncio.create_task(self._heartbeat_loop())
        logger.info(
            f"Heartbeat task started for '{self.service_name}' "
            f"(interval={self.interval_seconds}s)"
        )

    async def stop(self):
        self._running = False
        if self._task:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
        await self.client.close()
        logger.info(f"Heartbeat task stopped: {self.service_name}")


# ── CONVENIENCE HELPERS ───────────────────────────────────────────────────────

async def require_service(service_name: str) -> str:
    """
    Resolve a service URL by name. Raises RuntimeError if unavailable.
    Use for fail-fast service dependencies at startup.
    """
    client = ServiceRegistryClient()
    try:
        service = await client.get_service(service_name)
        if not service or not service.get("is_active"):
            raise RuntimeError(f"Required service '{service_name}' is not available")
        return service["service_url"]
    finally:
        await client.close()
