/**
 * SaaS Admin - DRAFT Rule Editor UI
 * 
 * Location: Copy to 2025-TrueVow-SaaS-Administration/app/(dashboard)/draft/rules/editor/page.tsx
 * 
 * Purpose: Create and edit validation rules with visual editor
 */

'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { 
  Save, 
  X, 
  Plus,
  Trash2,
  Code,
  Settings,
  CheckCircle,
  AlertTriangle,
  Info
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
    rules: {
      create: '/api/admin/draft/rules',
      update: (id: string) => `/api/admin/draft/rules/${id}`,
      get: (id: string) => `/api/admin/draft/rules/${id}`,
      delete: (id: string) => `/api/admin/draft/rules/${id}`
    }
  }
}

interface RuleFormData {
  rule_name: string
  practice_area: string
  document_type: string
  jurisdiction_state?: string
  validator_level: number
  validator_name: string
  validator_type: 'regex' | 'keyword' | 'length' | 'format' | 'custom'
  validator_config: {
    pattern?: string
    keywords?: string[]
    min_length?: number
    max_length?: number
    format?: string
    custom_function?: string
  }
  severity: 'error' | 'warning' | 'info'
  error_message?: string
  warning_message?: string
  info_message?: string
  is_active: boolean
  is_required: boolean
  is_enabled_for_validation: boolean
  notes?: string
}

export default function RuleEditorPage({ ruleId }: { ruleId?: string }) {
  const [formData, setFormData] = useState<RuleFormData>({
    rule_name: '',
    practice_area: '',
    document_type: '',
    jurisdiction_state: '',
    validator_level: 1,
    validator_name: '',
    validator_type: 'regex',
    validator_config: {},
    severity: 'error',
    error_message: '',
    warning_message: '',
    info_message: '',
    is_active: true,
    is_required: true,
    is_enabled_for_validation: true,
    notes: ''
  })
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (ruleId) {
      loadRule(ruleId)
    }
  }, [ruleId])

  const loadRule = async (id: string) => {
    setLoading(true)
    try {
      const url = `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.rules.get(id)}`
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok) {
        const data = await response.json()
        setFormData(data)
      }
    } catch (error) {
      console.error('Error loading rule:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const url = ruleId
        ? `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.rules.update(ruleId)}`
        : `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.rules.create}`

      const method = ruleId ? 'PUT' : 'POST'

      const response = await fetch(url, {
        method,
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(formData)
      })

      if (response.ok) {
        alert(ruleId ? 'Rule updated successfully' : 'Rule created successfully')
        if (!ruleId) {
          // Reset form for new rule
          setFormData({
            rule_name: '',
            practice_area: '',
            document_type: '',
            jurisdiction_state: '',
            validator_level: 1,
            validator_name: '',
            validator_type: 'regex',
            validator_config: {},
            severity: 'error',
            error_message: '',
            warning_message: '',
            info_message: '',
            is_active: true,
            is_required: true,
            is_enabled_for_validation: true,
            notes: ''
          })
        }
      } else {
        alert('Failed to save rule')
      }
    } catch (error) {
      console.error('Error saving rule:', error)
      alert('Failed to save rule')
    } finally {
      setSaving(false)
    }
  }

  const updateValidatorConfig = (key: string, value: any) => {
    setFormData({
      ...formData,
      validator_config: {
        ...formData.validator_config,
        [key]: value
      }
    })
  }

  if (loading) {
    return <div className="container mx-auto p-6">Loading rule...</div>
  }

  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">
          {ruleId ? 'Edit Rule' : 'Create New Rule'}
        </h1>
        <p className="text-gray-600">Define validation rules for document compliance</p>
      </div>

      <Card className="p-6">
        <div className="space-y-6">
          {/* Basic Information */}
          <div>
            <h2 className="text-xl font-semibold mb-4">Basic Information</h2>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Rule Name *</label>
                <Input
                  value={formData.rule_name}
                  onChange={(e) => setFormData({ ...formData, rule_name: e.target.value })}
                  placeholder="e.g., Required Signature Presence"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Practice Area *</label>
                <select
                  value={formData.practice_area}
                  onChange={(e) => setFormData({ ...formData, practice_area: e.target.value })}
                  className="w-full px-3 py-2 border rounded"
                >
                  <option value="">Select...</option>
                  <option value="personal_injury">Personal Injury</option>
                  <option value="family_law">Family Law</option>
                  <option value="criminal">Criminal</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Document Type *</label>
                <Input
                  value={formData.document_type}
                  onChange={(e) => setFormData({ ...formData, document_type: e.target.value })}
                  placeholder="e.g., demand_letter"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Jurisdiction State</label>
                <Input
                  value={formData.jurisdiction_state || ''}
                  onChange={(e) => setFormData({ ...formData, jurisdiction_state: e.target.value })}
                  placeholder="e.g., CA"
                />
              </div>
            </div>
          </div>

          {/* Validator Configuration */}
          <div>
            <h2 className="text-xl font-semibold mb-4">Validator Configuration</h2>
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium mb-2">Validator Level *</label>
                <select
                  value={formData.validator_level}
                  onChange={(e) => setFormData({ ...formData, validator_level: parseInt(e.target.value) })}
                  className="w-full px-3 py-2 border rounded"
                >
                  <option value={1}>Level 1 - Format</option>
                  <option value={2}>Level 2 - Content</option>
                  <option value={3}>Level 3 - Compliance</option>
                  <option value={4}>Level 4 - Quality</option>
                  <option value={5}>Level 5 - Custom</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Validator Type *</label>
                <select
                  value={formData.validator_type}
                  onChange={(e) => setFormData({ ...formData, validator_type: e.target.value as any })}
                  className="w-full px-3 py-2 border rounded"
                >
                  <option value="regex">Regex Pattern</option>
                  <option value="keyword">Keyword Search</option>
                  <option value="length">Length Check</option>
                  <option value="format">Format Validation</option>
                  <option value="custom">Custom Function</option>
                </select>
              </div>
            </div>

            {/* Validator Config Fields */}
            {formData.validator_type === 'regex' && (
              <div>
                <label className="block text-sm font-medium mb-2">Regex Pattern *</label>
                <Input
                  value={formData.validator_config.pattern || ''}
                  onChange={(e) => updateValidatorConfig('pattern', e.target.value)}
                  placeholder="e.g., ^[A-Z]{2}-\\d{4}$"
                />
              </div>
            )}

            {formData.validator_type === 'keyword' && (
              <div>
                <label className="block text-sm font-medium mb-2">Keywords (comma-separated) *</label>
                <Input
                  value={(formData.validator_config.keywords || []).join(', ')}
                  onChange={(e) => updateValidatorConfig('keywords', e.target.value.split(',').map(k => k.trim()))}
                  placeholder="e.g., signature, notarized, witness"
                />
              </div>
            )}

            {formData.validator_type === 'length' && (
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Min Length</label>
                  <Input
                    type="number"
                    value={formData.validator_config.min_length || ''}
                    onChange={(e) => updateValidatorConfig('min_length', parseInt(e.target.value))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Max Length</label>
                  <Input
                    type="number"
                    value={formData.validator_config.max_length || ''}
                    onChange={(e) => updateValidatorConfig('max_length', parseInt(e.target.value))}
                  />
                </div>
              </div>
            )}

            {formData.validator_type === 'custom' && (
              <div>
                <label className="block text-sm font-medium mb-2">Custom Function (JavaScript) *</label>
                <textarea
                  value={formData.validator_config.custom_function || ''}
                  onChange={(e) => updateValidatorConfig('custom_function', e.target.value)}
                  className="w-full px-3 py-2 border rounded font-mono text-sm"
                  rows={10}
                  placeholder="function validate(text) { return { passed: true, message: 'Valid' }; }"
                />
              </div>
            )}
          </div>

          {/* Severity and Messages */}
          <div>
            <h2 className="text-xl font-semibold mb-4">Severity and Messages</h2>
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium mb-2">Severity *</label>
                <select
                  value={formData.severity}
                  onChange={(e) => setFormData({ ...formData, severity: e.target.value as any })}
                  className="w-full px-3 py-2 border rounded"
                >
                  <option value="error">Error</option>
                  <option value="warning">Warning</option>
                  <option value="info">Info</option>
                </select>
              </div>
            </div>
            <div className="space-y-4">
              {formData.severity === 'error' && (
                <div>
                  <label className="block text-sm font-medium mb-2">Error Message</label>
                  <Input
                    value={formData.error_message || ''}
                    onChange={(e) => setFormData({ ...formData, error_message: e.target.value })}
                    placeholder="Error message to display"
                  />
                </div>
              )}
              {formData.severity === 'warning' && (
                <div>
                  <label className="block text-sm font-medium mb-2">Warning Message</label>
                  <Input
                    value={formData.warning_message || ''}
                    onChange={(e) => setFormData({ ...formData, warning_message: e.target.value })}
                    placeholder="Warning message to display"
                  />
                </div>
              )}
              {formData.severity === 'info' && (
                <div>
                  <label className="block text-sm font-medium mb-2">Info Message</label>
                  <Input
                    value={formData.info_message || ''}
                    onChange={(e) => setFormData({ ...formData, info_message: e.target.value })}
                    placeholder="Info message to display"
                  />
                </div>
              )}
            </div>
          </div>

          {/* Status Flags */}
          <div>
            <h2 className="text-xl font-semibold mb-4">Status Flags</h2>
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                  className="mr-2"
                />
                <span>Active</span>
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.is_required}
                  onChange={(e) => setFormData({ ...formData, is_required: e.target.checked })}
                  className="mr-2"
                />
                <span>Required</span>
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.is_enabled_for_validation}
                  onChange={(e) => setFormData({ ...formData, is_enabled_for_validation: e.target.checked })}
                  className="mr-2"
                />
                <span>Enabled for Validation</span>
              </label>
            </div>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-sm font-medium mb-2">Notes</label>
            <textarea
              value={formData.notes || ''}
              onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              className="w-full px-3 py-2 border rounded"
              rows={4}
              placeholder="Additional notes about this rule..."
            />
          </div>

          {/* Actions */}
          <div className="flex gap-2 justify-end">
            <Button variant="outline" onClick={() => window.history.back()}>
              <X size={16} className="mr-2" />
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={saving}>
              <Save size={16} className="mr-2" />
              {saving ? 'Saving...' : ruleId ? 'Update Rule' : 'Create Rule'}
            </Button>
          </div>
        </div>
      </Card>
    </div>
  )
}
