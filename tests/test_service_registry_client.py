"""
Tests for ServiceRegistryClient and HeartbeatTask
(app/services/service_registry_client.py)
All HTTP calls are mocked — no real registry needed.
"""

import asyncio
import pytest
from unittest.mock import MagicMock, AsyncMock, patch, PropertyMock

from app.services.service_registry_client import (
    ServiceConfig,
    ServiceRegistryClient,
    HeartbeatTask,
    require_service,
)


# ---------------------------------------------------------------------------
# ServiceConfig
# ---------------------------------------------------------------------------

class TestServiceConfig:

    def test_to_dict_has_all_keys(self):
        config = ServiceConfig(
            service_name="draft-service",
            service_type="backend",
            service_url="http://localhost:8001",
            port=8001,
            endpoints=[{"path": "/api/v1/health"}],
            agents=["validation-agent"],
            capabilities=["document-validation"],
        )
        d = config.to_dict()
        assert d["service_name"] == "draft-service"
        assert d["service_type"] == "backend"
        assert d["service_url"] == "http://localhost:8001"
        assert d["port"] == 8001
        assert d["endpoints"] == [{"path": "/api/v1/health"}]
        assert d["agents"] == ["validation-agent"]
        assert d["capabilities"] == ["document-validation"]

    def test_defaults_are_empty_lists(self):
        config = ServiceConfig(
            service_name="svc",
            service_type="api",
            service_url="http://svc",
            port=3000,
        )
        d = config.to_dict()
        assert d["endpoints"] == []
        assert d["agents"] == []
        assert d["capabilities"] == []


# ---------------------------------------------------------------------------
# ServiceRegistryClient._headers
# ---------------------------------------------------------------------------

class TestServiceRegistryClientHeaders:

    def test_includes_api_key_when_set(self):
        client = ServiceRegistryClient()
        client.api_key = "test-key-123"
        headers = client._headers()
        assert headers["X-Registry-API-Key"] == "test-key-123"
        assert headers["Content-Type"] == "application/json"

    def test_no_api_key_header_when_empty(self):
        client = ServiceRegistryClient()
        client.api_key = ""
        headers = client._headers()
        assert "X-Registry-API-Key" not in headers


# ---------------------------------------------------------------------------
# ServiceRegistryClient async methods
# ---------------------------------------------------------------------------

class TestServiceRegistryClientRegister:

    @pytest.mark.asyncio
    async def test_register_success(self):
        svc = ServiceRegistryClient()
        config = ServiceConfig(
            service_name="draft",
            service_type="backend",
            service_url="http://localhost:8001",
            port=8001,
        )
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"success": True, "id": "abc"}
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register(config)

        assert result["success"] is True

    @pytest.mark.asyncio
    async def test_register_returns_failure_on_exception(self):
        svc = ServiceRegistryClient()
        config = ServiceConfig(
            service_name="draft",
            service_type="backend",
            service_url="http://localhost:8001",
            port=8001,
        )
        mock_client = AsyncMock()
        mock_client.post.side_effect = Exception("connection refused")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register(config)

        assert result["success"] is False
        assert "connection refused" in result["error"]


class TestServiceRegistryClientHeartbeat:

    @pytest.mark.asyncio
    async def test_heartbeat_returns_json(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"status": "ok"}

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.heartbeat("draft-service")

        assert result["status"] == "ok"

    @pytest.mark.asyncio
    async def test_heartbeat_returns_failure_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.post.side_effect = Exception("timeout")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.heartbeat("draft-service")

        assert result["success"] is False

    @pytest.mark.asyncio
    async def test_heartbeat_default_status_is_alive(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"ok": True}

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            await svc.heartbeat("draft-service")

        call_kwargs = mock_client.post.call_args
        assert call_kwargs[1]["json"]["status"] == "alive"


class TestServiceRegistryClientGetService:

    @pytest.mark.asyncio
    async def test_get_service_returns_dict(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"service_name": "draft", "is_active": True}

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_service("draft")

        assert result["service_name"] == "draft"

    @pytest.mark.asyncio
    async def test_get_service_returns_none_on_404(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.status_code = 404

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_service("nonexistent")

        assert result is None

    @pytest.mark.asyncio
    async def test_get_service_returns_none_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.get.side_effect = Exception("network error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_service("draft")

        assert result is None


class TestServiceRegistryClientModules:

    @pytest.mark.asyncio
    async def test_register_module_success(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"success": True}
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register_module(
                service_name="draft",
                module_name="validation",
                description="Validation module",
            )

        assert result["success"] is True

    @pytest.mark.asyncio
    async def test_register_module_returns_failure_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.post.side_effect = Exception("error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register_module(
                service_name="draft",
                module_name="validation",
            )

        assert result["success"] is False

    @pytest.mark.asyncio
    async def test_get_modules_returns_list(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = [{"module_name": "validation"}]

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_modules("draft")

        assert isinstance(result, list)
        assert result[0]["module_name"] == "validation"

    @pytest.mark.asyncio
    async def test_get_modules_returns_empty_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.get.side_effect = Exception("error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_modules("draft")

        assert result == []


class TestServiceRegistryClientIntegrations:

    @pytest.mark.asyncio
    async def test_register_integration_success(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"success": True}
        mock_response.raise_for_status = MagicMock()

        mock_client = AsyncMock()
        mock_client.post.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register_integration(
                source_service="draft",
                target_service="billing",
                integration_type="REST",
                purpose="access check",
            )

        assert result["success"] is True

    @pytest.mark.asyncio
    async def test_register_integration_returns_failure_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.post.side_effect = Exception("error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.register_integration(
                source_service="draft",
                target_service="billing",
                integration_type="REST",
            )

        assert result["success"] is False

    @pytest.mark.asyncio
    async def test_get_integrations_returns_dict(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"receives_from": [], "sends_to": ["billing"]}

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_integrations("draft")

        assert "sends_to" in result

    @pytest.mark.asyncio
    async def test_get_integrations_returns_empty_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.get.side_effect = Exception("error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.get_integrations("draft")

        assert result == {"receives_from": [], "sends_to": []}

    @pytest.mark.asyncio
    async def test_find_by_event_returns_dict(self):
        svc = ServiceRegistryClient()
        mock_response = MagicMock()
        mock_response.json.return_value = {"publishers": ["svc-a"], "consumers": ["svc-b"]}

        mock_client = AsyncMock()
        mock_client.get.return_value = mock_response

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.find_by_event("validation.completed")

        assert "publishers" in result
        assert "consumers" in result

    @pytest.mark.asyncio
    async def test_find_by_event_returns_empty_on_exception(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        mock_client.get.side_effect = Exception("error")

        with patch.object(svc, "_get_client", return_value=mock_client):
            result = await svc.find_by_event("validation.completed")

        assert result == {"publishers": [], "consumers": []}


class TestServiceRegistryClientClose:

    @pytest.mark.asyncio
    async def test_close_calls_aclose(self):
        svc = ServiceRegistryClient()
        mock_client = AsyncMock()
        svc._client = mock_client

        await svc.close()

        mock_client.aclose.assert_called_once()
        assert svc._client is None

    @pytest.mark.asyncio
    async def test_close_safe_when_no_client(self):
        svc = ServiceRegistryClient()
        svc._client = None
        await svc.close()  # should not raise


# ---------------------------------------------------------------------------
# HeartbeatTask
# ---------------------------------------------------------------------------

class TestHeartbeatTask:

    def test_default_interval_from_env(self):
        with patch.dict("os.environ", {"SERVICE_HEARTBEAT_INTERVAL_S": "60"}):
            task = HeartbeatTask("draft-service")
        assert task.interval_seconds == 60

    def test_custom_interval_overrides_env(self):
        task = HeartbeatTask("draft-service", interval_seconds=30)
        assert task.interval_seconds == 30

    @pytest.mark.asyncio
    async def test_start_creates_task(self):
        task = HeartbeatTask("draft-service", interval_seconds=9999)
        await task.start()
        assert task._running is True
        assert task._task is not None
        # Stop immediately to avoid real heartbeat
        await task.stop()

    @pytest.mark.asyncio
    async def test_stop_sets_running_false(self):
        task = HeartbeatTask("draft-service", interval_seconds=9999)
        await task.start()
        await task.stop()
        assert task._running is False


# ---------------------------------------------------------------------------
# require_service helper
# ---------------------------------------------------------------------------

class TestRequireService:

    @pytest.mark.asyncio
    async def test_returns_url_when_service_active(self):
        mock_service_data = {"is_active": True, "service_url": "http://billing:3001"}

        with patch(
            "app.services.service_registry_client.ServiceRegistryClient.get_service",
            new_callable=AsyncMock,
            return_value=mock_service_data,
        ), patch(
            "app.services.service_registry_client.ServiceRegistryClient.close",
            new_callable=AsyncMock,
        ):
            url = await require_service("billing")

        assert url == "http://billing:3001"

    @pytest.mark.asyncio
    async def test_raises_runtime_error_when_service_not_found(self):
        with patch(
            "app.services.service_registry_client.ServiceRegistryClient.get_service",
            new_callable=AsyncMock,
            return_value=None,
        ), patch(
            "app.services.service_registry_client.ServiceRegistryClient.close",
            new_callable=AsyncMock,
        ):
            with pytest.raises(RuntimeError, match="not available"):
                await require_service("missing-service")

    @pytest.mark.asyncio
    async def test_raises_runtime_error_when_service_inactive(self):
        with patch(
            "app.services.service_registry_client.ServiceRegistryClient.get_service",
            new_callable=AsyncMock,
            return_value={"is_active": False, "service_url": "http://billing:3001"},
        ), patch(
            "app.services.service_registry_client.ServiceRegistryClient.close",
            new_callable=AsyncMock,
        ):
            with pytest.raises(RuntimeError, match="not available"):
                await require_service("billing")
