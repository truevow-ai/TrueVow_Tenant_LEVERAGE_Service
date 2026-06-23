/**
 * SaaS Admin - DRAFT Analytics Dashboard UI
 * 
 * Location: Copy to 2025-TrueVow-SaaS-Administration/app/(dashboard)/draft/analytics/page.tsx
 * 
 * Purpose: View comprehensive validation analytics across all tenants
 */

'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { 
  TrendingUp, 
  TrendingDown,
  BarChart3,
  PieChart,
  Users,
  FileText,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Calendar
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
    analytics: '/api/admin/draft/analytics'
  }
}

interface AnalyticsData {
  overview: {
    total_validations: number
    total_validations_trend: number
    success_rate: number
    success_rate_trend: number
    active_tenants: number
    active_tenants_trend: number
    average_validation_time: number
    average_validation_time_trend: number
  }
  practice_area_distribution: Array<{
    practice_area: string
    count: number
    percentage: number
  }>
  document_type_distribution: Array<{
    document_type: string
    count: number
    percentage: number
  }>
  severity_distribution: Array<{
    severity: string
    count: number
    percentage: number
  }>
  top_failing_rules: Array<{
    rule_id: string
    rule_name: string
    failure_count: number
    failure_rate: number
  }>
  tenant_usage: Array<{
    tenant_id: string
    tenant_name?: string
    validation_count: number
    success_rate: number
  }>
  timeline: Array<{
    date: string
    validations: number
    passed: number
    failed: number
  }>
}

export default function AnalyticsDashboardPage() {
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null)
  const [loading, setLoading] = useState(true)
  const [dateRange, setDateRange] = useState({
    from: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    to: new Date().toISOString().split('T')[0]
  })

  useEffect(() => {
    loadAnalytics()
  }, [dateRange])

  const loadAnalytics = async () => {
    setLoading(true)
    try {
      const url = `${DRAFT_API_CONFIG.apiUrl}${DRAFT_API_CONFIG.endpoints.analytics}?from_date=${dateRange.from}&to_date=${dateRange.to}`
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${DRAFT_API_CONFIG.getApiKey()}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok) {
        const data = await response.json()
        setAnalytics(data)
      }
    } catch (error) {
      console.error('Error loading analytics:', error)
    } finally {
      setLoading(false)
    }
  }

  const getTrendIcon = (trend: number) => {
    if (trend > 0) return <TrendingUp className="text-green-600" size={16} />
    if (trend < 0) return <TrendingDown className="text-red-600" size={16} />
    return null
  }

  const getTrendColor = (trend: number) => {
    if (trend > 0) return 'text-green-600'
    if (trend < 0) return 'text-red-600'
    return 'text-gray-600'
  }

  if (loading) {
    return <div className="container mx-auto p-6">Loading analytics...</div>
  }

  if (!analytics) {
    return <div className="container mx-auto p-6">No analytics data available</div>
  }

  return (
    <div className="container mx-auto p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">Analytics Dashboard</h1>
        <p className="text-gray-600">Comprehensive validation analytics across all tenants</p>
      </div>

      {/* Date Range Selector */}
      <Card className="p-4 mb-6">
        <div className="flex items-center gap-4">
          <Calendar size={20} />
          <input
            type="date"
            value={dateRange.from}
            onChange={(e) => setDateRange({ ...dateRange, from: e.target.value })}
            className="px-3 py-2 border rounded"
          />
          <span>to</span>
          <input
            type="date"
            value={dateRange.to}
            onChange={(e) => setDateRange({ ...dateRange, to: e.target.value })}
            className="px-3 py-2 border rounded"
          />
          <Button onClick={loadAnalytics}>Refresh</Button>
        </div>
      </Card>

      {/* Overview Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="text-sm text-gray-600">Total Validations</div>
            {getTrendIcon(analytics.overview.total_validations_trend)}
          </div>
          <div className="text-2xl font-bold">{analytics.overview.total_validations.toLocaleString()}</div>
          <div className={`text-sm ${getTrendColor(analytics.overview.total_validations_trend)}`}>
            {analytics.overview.total_validations_trend > 0 ? '+' : ''}
            {analytics.overview.total_validations_trend.toFixed(1)}%
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="text-sm text-gray-600">Success Rate</div>
            {getTrendIcon(analytics.overview.success_rate_trend)}
          </div>
          <div className="text-2xl font-bold">{analytics.overview.success_rate.toFixed(1)}%</div>
          <div className={`text-sm ${getTrendColor(analytics.overview.success_rate_trend)}`}>
            {analytics.overview.success_rate_trend > 0 ? '+' : ''}
            {analytics.overview.success_rate_trend.toFixed(1)}%
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="text-sm text-gray-600">Active Tenants</div>
            {getTrendIcon(analytics.overview.active_tenants_trend)}
          </div>
          <div className="text-2xl font-bold">{analytics.overview.active_tenants}</div>
          <div className={`text-sm ${getTrendColor(analytics.overview.active_tenants_trend)}`}>
            {analytics.overview.active_tenants_trend > 0 ? '+' : ''}
            {analytics.overview.active_tenants_trend.toFixed(1)}%
          </div>
        </Card>

        <Card className="p-4">
          <div className="flex items-center justify-between mb-2">
            <div className="text-sm text-gray-600">Avg Validation Time</div>
            {getTrendIcon(-analytics.overview.average_validation_time_trend)}
          </div>
          <div className="text-2xl font-bold">{analytics.overview.average_validation_time.toFixed(2)}s</div>
          <div className={`text-sm ${getTrendColor(-analytics.overview.average_validation_time_trend)}`}>
            {analytics.overview.average_validation_time_trend > 0 ? '+' : ''}
            {analytics.overview.average_validation_time_trend.toFixed(1)}%
          </div>
        </Card>
      </div>

      {/* Distributions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        {/* Practice Area Distribution */}
        <Card className="p-4">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <PieChart size={20} className="mr-2" />
            Practice Areas
          </h3>
          <div className="space-y-2">
            {analytics.practice_area_distribution.map((item, index) => (
              <div key={index}>
                <div className="flex justify-between text-sm mb-1">
                  <span>{item.practice_area}</span>
                  <span className="font-semibold">{item.count} ({item.percentage.toFixed(1)}%)</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full"
                    style={{ width: `${item.percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Document Type Distribution */}
        <Card className="p-4">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <FileText size={20} className="mr-2" />
            Document Types
          </h3>
          <div className="space-y-2">
            {analytics.document_type_distribution.map((item, index) => (
              <div key={index}>
                <div className="flex justify-between text-sm mb-1">
                  <span>{item.document_type}</span>
                  <span className="font-semibold">{item.count} ({item.percentage.toFixed(1)}%)</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-green-600 h-2 rounded-full"
                    style={{ width: `${item.percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>

        {/* Severity Distribution */}
        <Card className="p-4">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <AlertTriangle size={20} className="mr-2" />
            Severity Distribution
          </h3>
          <div className="space-y-2">
            {analytics.severity_distribution.map((item, index) => (
              <div key={index}>
                <div className="flex justify-between text-sm mb-1">
                  <span className="capitalize">{item.severity}</span>
                  <span className="font-semibold">{item.count} ({item.percentage.toFixed(1)}%)</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className={`h-2 rounded-full ${
                      item.severity === 'error' ? 'bg-red-600' :
                      item.severity === 'warning' ? 'bg-yellow-600' :
                      'bg-blue-600'
                    }`}
                    style={{ width: `${item.percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Top Failing Rules */}
      <Card className="p-4 mb-6">
        <h3 className="text-lg font-semibold mb-4">Top Failing Rules</h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left p-2">Rule Name</th>
                <th className="text-right p-2">Failure Count</th>
                <th className="text-right p-2">Failure Rate</th>
              </tr>
            </thead>
            <tbody>
              {analytics.top_failing_rules.map((rule, index) => (
                <tr key={index} className="border-b">
                  <td className="p-2">{rule.rule_name}</td>
                  <td className="text-right p-2">{rule.failure_count}</td>
                  <td className="text-right p-2">{rule.failure_rate.toFixed(1)}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Tenant Usage */}
      <Card className="p-4">
        <h3 className="text-lg font-semibold mb-4 flex items-center">
          <Users size={20} className="mr-2" />
          Tenant Usage
        </h3>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left p-2">Tenant</th>
                <th className="text-right p-2">Validations</th>
                <th className="text-right p-2">Success Rate</th>
              </tr>
            </thead>
            <tbody>
              {analytics.tenant_usage.map((tenant, index) => (
                <tr key={index} className="border-b">
                  <td className="p-2">{tenant.tenant_name || tenant.tenant_id}</td>
                  <td className="text-right p-2">{tenant.validation_count}</td>
                  <td className="text-right p-2">
                    <Badge className={
                      tenant.success_rate >= 90 ? 'bg-green-100 text-green-800' :
                      tenant.success_rate >= 70 ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    }>
                      {tenant.success_rate.toFixed(1)}%
                    </Badge>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}
