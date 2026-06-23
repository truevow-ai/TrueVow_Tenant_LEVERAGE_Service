/**
 * SaaS Admin - DRAFT Compliance Reports UI
 * 
 * Location: Copy to 2025-TrueVow-SaaS-Administration/app/(dashboard)/draft/compliance/page.tsx
 * 
 * Purpose: Generate and view ABA compliance reports for all tenants
 */

'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { 
  FileText, 
  Download, 
  Calendar, 
  TrendingUp, 
  TrendingDown,
  AlertTriangle,
  CheckCircle,
  XCircle
} from 'lucide-react'

interface ComplianceReport {
  report_id: string
  generated_at: string
  generated_by: string
  date_range: {
    from: string
    to: string
  }
  overall_score: number
  tenant_count: number
  total_validations: number
  compliance_breakdown: {
    format: number
    content: number
    compliance: number
    quality: number
  }
  top_violations: Array<{
    rule_id: string
    rule_name: string
    violation_count: number
    affected_tenants: number
    severity: 'error' | 'warning' | 'info'
  }>
  tenant_compliance: Array<{
    tenant_id: string
    tenant_name: string
    compliance_score: number
    violations_count: number
    last_validation: string
    status: 'compliant' | 'at-risk' | 'non-compliant'
  }>
}

export default function ComplianceReportsPage() {
  const [dateRange, setDateRange] = useState({
    from: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    to: new Date().toISOString().split('T')[0]
  })
  const [selectedTenant, setSelectedTenant] = useState<string>('')
  const [practiceArea, setPracticeArea] = useState<string>('')
  const [loading, setLoading] = useState(false)
  const [report, setReport] = useState<ComplianceReport | null>(null)
  const [reportsHistory, setReportsHistory] = useState<ComplianceReport[]>([])
  const [exportFormat, setExportFormat] = useState<'pdf' | 'csv' | 'json'>('pdf')

  // Load reports history on mount
  useEffect(() => {
    loadReportsHistory()
  }, [])

  const loadReportsHistory = async () => {
    try {
      const response = await fetch('/api/admin/draft/compliance/reports?limit=10')
      if (response.ok) {
        const data = await response.json()
        setReportsHistory(data.reports || [])
      }
    } catch (error) {
      console.error('Error loading reports history:', error)
    }
  }

  const generateReport = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/admin/draft/compliance/reports', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          from_date: dateRange.from,
          to_date: dateRange.to,
          tenant_id: selectedTenant || undefined,
          practice_area: practiceArea || undefined
        })
      })

      if (!response.ok) {
        throw new Error('Failed to generate report')
      }

      const data = await response.json()
      setReport(data)
      
      // Refresh history
      loadReportsHistory()
    } catch (error) {
      console.error('Error generating report:', error)
      alert('Failed to generate compliance report. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const exportReport = async (reportId: string) => {
    try {
      const response = await fetch(
        `/api/admin/draft/compliance/reports/${reportId}/export?format=${exportFormat}`
      )
      
      if (!response.ok) {
        throw new Error('Export failed')
      }

      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `compliance-report-${reportId}.${exportFormat}`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      console.error('Error exporting report:', error)
      alert('Failed to export report')
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'compliant':
        return 'bg-green-100 text-green-800'
      case 'at-risk':
        return 'bg-yellow-100 text-yellow-800'
      case 'non-compliant':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'compliant':
        return <CheckCircle className="w-4 h-4" />
      case 'at-risk':
        return <AlertTriangle className="w-4 h-4" />
      case 'non-compliant':
        return <XCircle className="w-4 h-4" />
      default:
        return null
    }
  }

  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Compliance Reports</h1>
          <p className="text-gray-600 mt-1">Generate and view ABA compliance reports</p>
        </div>
      </div>

      {/* Generate Report Section */}
      <Card className="p-6">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
          <FileText className="w-5 h-5" />
          Generate New Report
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div>
            <label className="block text-sm font-medium mb-2">From Date</label>
            <input
              type="date"
              value={dateRange.from}
              onChange={(e) => setDateRange({ ...dateRange, from: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2">To Date</label>
            <input
              type="date"
              value={dateRange.to}
              onChange={(e) => setDateRange({ ...dateRange, to: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2">Practice Area (Optional)</label>
            <select
              value={practiceArea}
              onChange={(e) => setPracticeArea(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md"
            >
              <option value="">All Practice Areas</option>
              <option value="personal_injury">Personal Injury</option>
              <option value="family_law">Family Law</option>
              <option value="criminal_law">Criminal Law</option>
              <option value="corporate_law">Corporate Law</option>
            </select>
          </div>
        </div>

        <Button 
          onClick={generateReport} 
          disabled={loading}
          className="w-full md:w-auto"
        >
          {loading ? 'Generating Report...' : 'Generate Report'}
        </Button>
      </Card>

      {/* Current Report Display */}
      {report && (
        <Card className="p-6">
          <div className="flex justify-between items-start mb-6">
            <div>
              <h2 className="text-xl font-semibold mb-2">Compliance Report</h2>
              <p className="text-sm text-gray-600">
                Generated: {new Date(report.generated_at).toLocaleString()}
              </p>
              <p className="text-sm text-gray-600">
                Period: {new Date(report.date_range.from).toLocaleDateString()} - {new Date(report.date_range.to).toLocaleDateString()}
              </p>
            </div>
            <div className="flex gap-2">
              <select
                value={exportFormat}
                onChange={(e) => setExportFormat(e.target.value as 'pdf' | 'csv' | 'json')}
                className="px-3 py-2 border border-gray-300 rounded-md text-sm"
              >
                <option value="pdf">PDF</option>
                <option value="csv">CSV</option>
                <option value="json">JSON</option>
              </select>
              <Button
                onClick={() => exportReport(report.report_id)}
                variant="outline"
                size="sm"
              >
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
            </div>
          </div>

          {/* Overall Score */}
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="text-lg font-semibold">Overall Compliance Score</span>
              <span className="text-2xl font-bold text-blue-600">{report.overall_score}%</span>
            </div>
            <Progress value={report.overall_score} className="h-3" />
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Total Validations</div>
              <div className="text-2xl font-bold">{report.total_validations.toLocaleString()}</div>
            </div>
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Active Tenants</div>
              <div className="text-2xl font-bold">{report.tenant_count}</div>
            </div>
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Compliant Tenants</div>
              <div className="text-2xl font-bold text-green-600">
                {report.tenant_compliance.filter(t => t.status === 'compliant').length}
              </div>
            </div>
            <div className="bg-gray-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">At Risk</div>
              <div className="text-2xl font-bold text-yellow-600">
                {report.tenant_compliance.filter(t => t.status === 'at-risk').length}
              </div>
            </div>
          </div>

          {/* Compliance Breakdown */}
          <div className="mb-6">
            <h3 className="text-lg font-semibold mb-4">Compliance Breakdown</h3>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div>
                <div className="flex justify-between mb-1">
                  <span className="text-sm">Format</span>
                  <span className="text-sm font-semibold">{report.compliance_breakdown.format}%</span>
                </div>
                <Progress value={report.compliance_breakdown.format} className="h-2" />
              </div>
              <div>
                <div className="flex justify-between mb-1">
                  <span className="text-sm">Content</span>
                  <span className="text-sm font-semibold">{report.compliance_breakdown.content}%</span>
                </div>
                <Progress value={report.compliance_breakdown.content} className="h-2" />
              </div>
              <div>
                <div className="flex justify-between mb-1">
                  <span className="text-sm">Compliance</span>
                  <span className="text-sm font-semibold">{report.compliance_breakdown.compliance}%</span>
                </div>
                <Progress value={report.compliance_breakdown.compliance} className="h-2" />
              </div>
              <div>
                <div className="flex justify-between mb-1">
                  <span className="text-sm">Quality</span>
                  <span className="text-sm font-semibold">{report.compliance_breakdown.quality}%</span>
                </div>
                <Progress value={report.compliance_breakdown.quality} className="h-2" />
              </div>
            </div>
          </div>

          {/* Top Violations */}
          {report.top_violations.length > 0 && (
            <div className="mb-6">
              <h3 className="text-lg font-semibold mb-4">Top Violations</h3>
              <div className="space-y-2">
                {report.top_violations.map((violation, index) => (
                  <div key={violation.rule_id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <span className="text-gray-500">#{index + 1}</span>
                      <div>
                        <div className="font-medium">{violation.rule_name}</div>
                        <div className="text-sm text-gray-600">
                          {violation.affected_tenants} tenant(s) affected
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <Badge variant={violation.severity === 'error' ? 'destructive' : 'secondary'}>
                        {violation.severity}
                      </Badge>
                      <span className="font-semibold">{violation.violation_count}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Tenant Compliance Table */}
          <div>
            <h3 className="text-lg font-semibold mb-4">Tenant Compliance</h3>
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="bg-gray-50">
                    <th className="border border-gray-200 px-4 py-2 text-left">Tenant</th>
                    <th className="border border-gray-200 px-4 py-2 text-left">Score</th>
                    <th className="border border-gray-200 px-4 py-2 text-left">Violations</th>
                    <th className="border border-gray-200 px-4 py-2 text-left">Last Validation</th>
                    <th className="border border-gray-200 px-4 py-2 text-left">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {report.tenant_compliance.map((tenant) => (
                    <tr key={tenant.tenant_id}>
                      <td className="border border-gray-200 px-4 py-2">{tenant.tenant_name}</td>
                      <td className="border border-gray-200 px-4 py-2">
                        <div className="flex items-center gap-2">
                          <Progress value={tenant.compliance_score} className="w-20 h-2" />
                          <span className="text-sm font-semibold">{tenant.compliance_score}%</span>
                        </div>
                      </td>
                      <td className="border border-gray-200 px-4 py-2">{tenant.violations_count}</td>
                      <td className="border border-gray-200 px-4 py-2">
                        {new Date(tenant.last_validation).toLocaleDateString()}
                      </td>
                      <td className="border border-gray-200 px-4 py-2">
                        <Badge className={getStatusColor(tenant.status)}>
                          <span className="flex items-center gap-1">
                            {getStatusIcon(tenant.status)}
                            {tenant.status}
                          </span>
                        </Badge>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </Card>
      )}

      {/* Reports History */}
      <Card className="p-6">
        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5" />
          Report History
        </h2>
        
        {reportsHistory.length === 0 ? (
          <p className="text-gray-600 text-center py-8">No reports generated yet</p>
        ) : (
          <div className="space-y-3">
            {reportsHistory.map((histReport) => (
              <div
                key={histReport.report_id}
                className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition"
              >
                <div>
                  <div className="font-medium">
                    Report from {new Date(histReport.date_range.from).toLocaleDateString()} to{' '}
                    {new Date(histReport.date_range.to).toLocaleDateString()}
                  </div>
                  <div className="text-sm text-gray-600 mt-1">
                    Generated: {new Date(histReport.generated_at).toLocaleString()} |{' '}
                    Score: {histReport.overall_score}% | Tenants: {histReport.tenant_count}
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setReport(histReport)}
                  >
                    View
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => exportReport(histReport.report_id)}
                  >
                    <Download className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  )
}
