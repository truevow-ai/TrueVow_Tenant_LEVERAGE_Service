/**
 * SaaS Admin - DRAFT Template Browser UI
 * 
 * Location: Copy to 2025-TrueVow-SaaS-Administration/app/(dashboard)/draft/templates/page.tsx
 * 
 * Purpose: Browse, create, edit, and manage global validation rule templates
 */

'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { 
  FileText, 
  Plus, 
  Edit, 
  Trash2, 
  Search,
  Filter,
  Copy,
  Eye,
  CheckCircle,
  XCircle,
  AlertTriangle
} from 'lucide-react'

// DRAFT API Configuration
const DRAFT_API_CONFIG = {
  apiUrl: process.env.NEXT_PUBLIC_DRAFT_API_URL || 'https://draft.truevow.law',
  getApiKey: (): string => {
    if (process.env.DRAFT_API_KEY) {
      return process.env.DRAFT_API_KEY;
    }
    if (typeof window !== 'undefined' && (window as any).DRAFT_API_KEY) {
      return (window as any).DRAFT_API_KEY;
    }
    return '';
  },
  endpoints: {
    templates: {
      list: '/api/admin/draft/templates',
      get: (id: string) => `/api/admin/draft/templates/${id}`,
      create: '/api/admin/draft/templates',
      update: (id: string) => `/api/admin/draft/templates/${id}`,
      delete: (id: string) => `/api/admin/draft/templates/${id}`,
      stats: '/api/admin/draft/templates/stats'
    }
  }
}

interface Template {
  id: string
  template_name: string
  template_description?: string
  rule_name: string
  practice_area: string
  document_type: string
  jurisdiction_state?: string
  validator_level: number
  validator_name: string
  validator_type: string
  validator_config: any
  severity: 'error' | 'warning' | 'info'
  is_active: boolean
  inheritance_count: number
  created_at: string
  updated_at?: string
}

interface TemplateStats {
  total_templates: number
  active_templates: number
  practice_areas: number
  total_rules: number
  most_inherited: string
}

export default function TemplateBrowserPage() {
  const [templates, setTemplates] = useState<Template[]>([])
  const [stats, setStats] = useState<TemplateStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filters, setFilters] = useState({
    practice_area: '',
    document_type: '',
    severity: '',
    is_active: null as boolean | null
  })
  const [selectedTemplate, setSelectedTemplate] = useState<Template | null>(null)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showEditModal, setShowEditModal] = useState(false)

  useEffect(() => {
    loadTemplates()
    loadStats()
  }, [filters])

  const loadTemplates = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams()
      if (filters.practice_area) params.append('practice_area', filters.practice_area)
      if (filters.document_type) params.append('document_type', filters.document_type)
      if (filters.severity) params.append('severity', filters.severity)
      if (filters.is_active !== null) params.append('is_active', String(filters.is_active))

      const url = `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.templates.list}?${params.toString()}`
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok) {
        const data = await response.json()
        setTemplates(data.templates || [])
      }
    } catch (error) {
      console.error('Error loading templates:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadStats = async () => {
    try {
      const url = `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.templates.stats}`
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok) {
        const data = await response.json()
        setStats(data)
      }
    } catch (error) {
      console.error('Error loading stats:', error)
    }
  }

  const handleDelete = async (templateId: string) => {
    if (!confirm('Are you sure you want to delete this template? This will affect all rules that inherited from it.')) {
      return
    }

    try {
      const url = `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.templates.delete(templateId)}`
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok) {
        loadTemplates()
        loadStats()
      }
    } catch (error) {
      console.error('Error deleting template:', error)
      alert('Failed to delete template')
    }
  }

  const filteredTemplates = templates.filter(template => {
    if (searchTerm) {
      const search = searchTerm.toLowerCase()
      return (
        template.template_name.toLowerCase().includes(search) ||
        template.rule_name.toLowerCase().includes(search) ||
        template.practice_area.toLowerCase().includes(search) ||
        template.document_type.toLowerCase().includes(search)
      )
    }
    return true
  })

  return (
    <div className="container mx-auto p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">Template Browser</h1>
        <p className="text-gray-600">Manage global validation rule templates</p>
      </div>

      {/* Stats Cards */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
          <Card className="p-4">
            <div className="text-sm text-gray-600">Total Templates</div>
            <div className="text-2xl font-bold">{stats.total_templates}</div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-gray-600">Active</div>
            <div className="text-2xl font-bold text-green-600">{stats.active_templates}</div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-gray-600">Practice Areas</div>
            <div className="text-2xl font-bold">{stats.practice_areas}</div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-gray-600">Total Rules</div>
            <div className="text-2xl font-bold">{stats.total_rules}</div>
          </Card>
          <Card className="p-4">
            <div className="text-sm text-gray-600">Most Inherited</div>
            <div className="text-lg font-semibold truncate">{stats.most_inherited}</div>
          </Card>
        </div>
      )}

      {/* Search and Filters */}
      <Card className="p-4 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <Input
                placeholder="Search templates..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>
          <div className="flex gap-2">
            <select
              value={filters.practice_area}
              onChange={(e) => setFilters({ ...filters, practice_area: e.target.value })}
              className="px-3 py-2 border rounded"
            >
              <option value="">All Practice Areas</option>
              <option value="personal_injury">Personal Injury</option>
              <option value="family_law">Family Law</option>
              <option value="criminal">Criminal</option>
            </select>
            <select
              value={filters.severity}
              onChange={(e) => setFilters({ ...filters, severity: e.target.value })}
              className="px-3 py-2 border rounded"
            >
              <option value="">All Severities</option>
              <option value="error">Error</option>
              <option value="warning">Warning</option>
              <option value="info">Info</option>
            </select>
            <select
              value={filters.is_active === null ? '' : String(filters.is_active)}
              onChange={(e) => setFilters({ ...filters, is_active: e.target.value === '' ? null : e.target.value === 'true' })}
              className="px-3 py-2 border rounded"
            >
              <option value="">All Status</option>
              <option value="true">Active</option>
              <option value="false">Inactive</option>
            </select>
          </div>
          <Button onClick={() => setShowCreateModal(true)}>
            <Plus size={20} className="mr-2" />
            Create Template
          </Button>
        </div>
      </Card>

      {/* Templates List */}
      {loading ? (
        <div className="text-center py-12">Loading templates...</div>
      ) : filteredTemplates.length === 0 ? (
        <Card className="p-12 text-center">
          <FileText size={48} className="mx-auto text-gray-400 mb-4" />
          <p className="text-gray-600">No templates found</p>
        </Card>
      ) : (
        <div className="grid grid-cols-1 gap-4">
          {filteredTemplates.map((template) => (
            <Card key={template.id} className="p-4">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <h3 className="text-lg font-semibold">{template.template_name}</h3>
                    {template.is_active ? (
                      <Badge className="bg-green-100 text-green-800">Active</Badge>
                    ) : (
                      <Badge className="bg-gray-100 text-gray-800">Inactive</Badge>
                    )}
                    <Badge className={
                      template.severity === 'error' ? 'bg-red-100 text-red-800' :
                      template.severity === 'warning' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-blue-100 text-blue-800'
                    }>
                      {template.severity}
                    </Badge>
                  </div>
                  {template.template_description && (
                    <p className="text-gray-600 text-sm mb-2">{template.template_description}</p>
                  )}
                  <div className="flex flex-wrap gap-2 text-sm text-gray-500">
                    <span><strong>Rule:</strong> {template.rule_name}</span>
                    <span>•</span>
                    <span><strong>Practice Area:</strong> {template.practice_area}</span>
                    <span>•</span>
                    <span><strong>Document Type:</strong> {template.document_type}</span>
                    {template.jurisdiction_state && (
                      <>
                        <span>•</span>
                        <span><strong>State:</strong> {template.jurisdiction_state}</span>
                      </>
                    )}
                    <span>•</span>
                    <span><strong>Level:</strong> {template.validator_level}</span>
                    <span>•</span>
                    <span><strong>Inherited by:</strong> {template.inheritance_count} rules</span>
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setSelectedTemplate(template)
                      setShowEditModal(true)
                    }}
                  >
                    <Edit size={16} />
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleDelete(template.id)}
                    className="text-red-600"
                  >
                    <Trash2 size={16} />
                  </Button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Create/Edit Modals would go here - simplified for now */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="p-6 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold mb-4">Create Template</h2>
            <p className="text-gray-600 mb-4">Template creation form would go here</p>
            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => setShowCreateModal(false)}>Cancel</Button>
              <Button onClick={() => {
                // Create template logic
                setShowCreateModal(false)
                loadTemplates()
              }}>Create</Button>
            </div>
          </Card>
        </div>
      )}

      {showEditModal && selectedTemplate && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <Card className="p-6 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold mb-4">Edit Template</h2>
            <p className="text-gray-600 mb-4">Template editing form would go here</p>
            <div className="flex gap-2 justify-end">
              <Button variant="outline" onClick={() => {
                setShowEditModal(false)
                setSelectedTemplate(null)
              }}>Cancel</Button>
              <Button onClick={() => {
                // Update template logic
                setShowEditModal(false)
                setSelectedTemplate(null)
                loadTemplates()
              }}>Save</Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  )
}
