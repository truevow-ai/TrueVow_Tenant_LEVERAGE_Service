// DRAFT Service - SaaS Admin API Configuration
// Add this to SaaS Admin's API configuration

export const DRAFT_API_CONFIG = {
    // DRAFT service URL
    apiUrl: process.env.NEXT_PUBLIC_DRAFT_API_URL || 'https://draft.truevow.law',
    
    // Get API key from SaaS Admin auth system
    getApiKey: (): string => {
        // Option 1: From environment variable
        if (process.env.DRAFT_API_KEY) {
            return process.env.DRAFT_API_KEY;
        }
        
        // Option 2: From SaaS Admin auth system
        // Replace with your SaaS Admin's auth system
        if (typeof window !== 'undefined' && (window as any).DRAFT_API_KEY) {
            return (window as any).DRAFT_API_KEY;
        }
        
        return '';
    },
    
    // API endpoints
    endpoints: {
        compliance: {
            generateReport: '/api/admin/draft/compliance/reports',
            listReports: '/api/admin/draft/compliance/reports',
            getReport: (id: string) => `/api/admin/draft/compliance/reports/${id}`,
            exportReport: (id: string, format: 'pdf' | 'csv' | 'json') => 
                `/api/admin/draft/compliance/reports/${id}/export?format=${format}`
        }
    }
};

// Usage in compliance-reports-page.tsx:
// Update fetch calls to use DRAFT_API_CONFIG.apiUrl
// Example:
// const response = await fetch(`${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.compliance.generateReport}`, {
//     method: 'POST',
//     headers: {
//         'Content-Type': 'application/json',
//         'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`
//     },
//     body: JSON.stringify({ ... })
// });
