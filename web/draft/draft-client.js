// TrueVow DRAFT™ - API Client for Customer Portal

class DraftClient {
    constructor(config) {
        this.apiUrl = config.apiUrl || 'http://localhost:8003';
        this.apiKey = config.apiKey || '';
    }

    async request(endpoint, options = {}) {
        const url = `${this.apiUrl}${endpoint}`;
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };

        if (this.apiKey) {
            headers['Authorization'] = `Bearer ${this.apiKey}`;
            headers['X-API-Key'] = this.apiKey;
        }

        const response = await fetch(url, {
            ...options,
            headers
        });

        if (!response.ok) {
            const error = await response.json().catch(() => ({ detail: response.statusText }));
            throw new Error(error.detail || `HTTP ${response.status}`);
        }

        return response.json();
    }

    async validateDocument(documentText, options = {}) {
        return this.request('/api/v1/validation/validate', {
            method: 'POST',
            body: JSON.stringify({
                tenant_id: options.tenant_id || 'default',
                document_type: options.document_type || 'demand_letter',
                jurisdiction: options.jurisdiction || 'arizona',
                document_text: documentText,
                practice_area: options.practice_area
            })
        });
    }

    async validateFile(file, options = {}) {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('tenant_id', options.tenant_id || 'default');
        formData.append('document_type', options.document_type || 'demand_letter');
        if (options.jurisdiction) {
            formData.append('jurisdiction', options.jurisdiction);
        }
        if (options.practice_area) {
            formData.append('practice_area', options.practice_area);
        }

        const url = `${this.apiUrl}/api/v1/validation/validate-file`;
        const headers = {};

        if (this.apiKey) {
            headers['Authorization'] = `Bearer ${this.apiKey}`;
            headers['X-API-Key'] = this.apiKey;
        }

        const response = await fetch(url, {
            method: 'POST',
            headers,
            body: formData
        });

        if (!response.ok) {
            const error = await response.json().catch(() => ({ detail: response.statusText }));
            throw new Error(error.detail || `HTTP ${response.status}`);
        }

        return response.json();
    }

    async getValidationRules(options = {}) {
        const params = new URLSearchParams();
        if (options.tenant_id) params.append('tenant_id', options.tenant_id);
        if (options.document_type) params.append('document_type', options.document_type);
        if (options.jurisdiction) params.append('jurisdiction', options.jurisdiction);
        if (options.practice_area) params.append('practice_area', options.practice_area);

        return this.request(`/api/v1/validation/rules?${params.toString()}`);
    }

    async getValidationHistory(options = {}) {
        const params = new URLSearchParams();
        if (options.from_date) params.append('from_date', options.from_date);
        if (options.to_date) params.append('to_date', options.to_date);
        if (options.document_type) params.append('document_type', options.document_type);
        if (options.limit) params.append('limit', options.limit);
        if (options.offset) params.append('offset', options.offset);

        return this.request(`/api/v1/validation/history?${params.toString()}`);
    }
}
