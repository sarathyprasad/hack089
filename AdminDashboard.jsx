import React, { useState, useEffect } from 'react';
import { api } from '../services/api';
import { useAuth } from '../context/AuthContext';
import {
  Building2, Users, CheckCircle2, XCircle, Clock, AlertTriangle,
  TrendingUp, IndianRupee, ShieldCheck, Search, Filter,
  Calendar, Eye, Award, Check, X, RefreshCw, BarChart3,
  MapPin, Zap, ChevronRight, Sparkles, ArrowRight, Layers,
  Compass, Lightbulb, Share2, ShieldAlert, Wrench, HelpCircle, HeartPulse
} from 'lucide-react';

export default function AdminDashboard() {
  const { user } = useAuth();

  const [dashboardData, setDashboardData] = useState(null);
  const [workers, setWorkers] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [forecastData, setForecastData] = useState(null);
  const [allocationData, setAllocationData] = useState(null);
  const [liveMapData, setLiveMapData] = useState(null);
  const [disputes, setDisputes] = useState([]);
  const [sosAlerts, setSosAlerts] = useState([]);
  const [loading, setLoading] = useState(true);

  // Tabs: WORKERS, BOOKINGS, LIVE_MAP, DISPUTES, SOS_ALERTS, SMART_AI, WELFARE
  const [activeTab, setActiveTab] = useState('LIVE_MAP');

  // Filters
  const [workerStatusFilter, setWorkerStatusFilter] = useState('ALL');
  const [workerSearch, setWorkerSearch] = useState('');
  const [actionBusyId, setActionBusyId] = useState(null);
  const [bookingStatusFilter, setBookingStatusFilter] = useState('ALL');
  const [emergencyOnly, setEmergencyOnly] = useState(false);

  // Dispute resolution state
  const [selectedDispute, setSelectedDispute] = useState(null);
  const [resolutionNotes, setResolutionNotes] = useState('');
  const [resolvingDispute, setResolvingDispute] = useState(false);

  // Selected Worker Modal
  const [selectedWorker, setSelectedWorker] = useState(null);
  const [mutualAidBusyId, setMutualAidBusyId] = useState(null);
  const [mutualAidMsg, setMutualAidMsg] = useState('');

  const loadAllData = () => {
    setLoading(true);
    Promise.all([
      api.getAdminDashboard(),
      api.getAdminWorkers(),
      api.getAdminBookings(),
      api.getDemandForecast(),
      api.getWorkforceAllocation(),
      api.getLiveMap(),
      api.getDisputes(),
      api.getSosAlerts(),
    ])
      .then(([dashRes, workersRes, bookingsRes, forecastRes, allocRes, mapRes, dispRes, sosRes]) => {
        setDashboardData(dashRes);
        setWorkers(workersRes.workers || []);
        setBookings(bookingsRes.bookings || []);
        setForecastData(forecastRes);
        setAllocationData(allocRes);
        setLiveMapData(mapRes);
        setDisputes(dispRes.disputes || []);
        setSosAlerts(sosRes.alerts || []);
      })
      .catch((err) => console.error('Failed to load admin data:', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadAllData();
  }, []);

  const handleVerifyWorker = async (workerId, newStatus, reason = '') => {
    setActionBusyId(workerId);
    try {
      await api.verifyWorker(workerId, newStatus, reason);
      const [dashRes, workersRes] = await Promise.all([
        api.getAdminDashboard(),
        api.getAdminWorkers(),
      ]);
      setDashboardData(dashRes);
      setWorkers(workersRes.workers || []);
      if (selectedWorker && selectedWorker.id === workerId) {
        const updated = workersRes.workers.find((w) => w.id === workerId);
        setSelectedWorker(updated || { ...selectedWorker, verification_status: newStatus, rejection_reason: reason });
      }
    } catch (err) {
      console.error('Worker verification error:', err);
      alert('Failed to update verification status.');
    } finally {
      setActionBusyId(null);
    }
  };

  const handleApproveMutualAid = async (proposalId) => {
    setMutualAidBusyId(proposalId);
    try {
      await api.approveMutualAid(proposalId);
      setMutualAidMsg(`Mutual Aid ${proposalId} approved: temporary inter-cooperative worker transfer authorized.`);
      const allocRes = await api.getWorkforceAllocation();
      setAllocationData(allocRes);
    } catch (err) {
      console.error('Mutual aid approval error:', err);
    } finally {
      setMutualAidBusyId(null);
    }
  };

  const handleResolveDispute = async (e) => {
    e.preventDefault();
    if (!selectedDispute) return;
    setResolvingDispute(true);
    try {
      await api.resolveDispute(selectedDispute.id, resolutionNotes);
      alert('Dispute marked as RESOLVED by Federation Arbitrator.');
      setSelectedDispute(null);
      setResolutionNotes('');
      const dispRes = await api.getDisputes();
      setDisputes(dispRes.disputes || []);
    } catch (err) {
      alert(err.message || 'Failed to resolve dispute.');
    } finally {
      setResolvingDispute(false);
    }
  };

  if (loading) {
    return (
      <div className="container py-20 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
        <p className="text-xs text-gray-500">Loading cooperative federation administration portal...</p>
      </div>
    );
  }

  const { statistics } = dashboardData || {};

  const filteredWorkers = workers.filter((w) => {
    const matchesStatus = workerStatusFilter === 'ALL' || w.verification_status === workerStatusFilter;
    const matchesSearch =
      w.name.toLowerCase().includes(workerSearch.toLowerCase()) ||
      w.worker_code.toLowerCase().includes(workerSearch.toLowerCase()) ||
      w.cooperative_name.toLowerCase().includes(workerSearch.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const filteredBookings = bookings.filter((b) => {
    const matchesStatus = bookingStatusFilter === 'ALL' || b.status === bookingStatusFilter;
    const matchesEmergency = !emergencyOnly || b.is_emergency === 1;
    return matchesStatus && matchesEmergency;
  });

  // Calculate Welfare Corpus (5% of lifetime gross)
  const totalVolume = statistics?.totalWorkerEarnings || 150000;
  const welfareCorpus = Math.round(totalVolume * 0.05);

  return (
    <div className="container py-8 max-w-7xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200 pb-5">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded bg-blue-100 text-blue-950 text-xs font-bold uppercase tracking-wider mb-1">
            <Building2 size={14} /> Federation Administration & Oversight
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            Cooperative Governance Dashboard
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Logged in as <strong>{user?.name}</strong> • Khordha, Cuttack & Puri Labour Federations
          </p>
        </div>

        <button
          onClick={loadAllData}
          className="btn btn-secondary btn-sm flex items-center gap-1.5 text-xs self-start md:self-auto"
        >
          <RefreshCw size={13} /> Refresh Live Data
        </button>
      </div>

      {/* ── 7 Statistics Cards Grid ── */}
      <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-3">
        <div className="bg-white p-3.5 rounded-xl border border-gray-200 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-gray-400 block mb-1">Total Workers</span>
          <div className="text-xl font-bold text-blue-950 font-mono">{statistics?.totalWorkers || 0}</div>
          <span className="text-[10px] text-gray-500">Registered pool</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-emerald-200 bg-emerald-50/20 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-emerald-700 block mb-1">Verified</span>
          <div className="text-xl font-bold text-emerald-800 font-mono">{statistics?.verifiedWorkers || 0}</div>
          <span className="text-[10px] text-emerald-700 font-semibold">Active trade cards</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-amber-200 bg-amber-50/20 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-amber-700 block mb-1">Pending KYC</span>
          <div className="text-xl font-bold text-amber-800 font-mono">{statistics?.pendingWorkers || 0}</div>
          <span className="text-[10px] text-amber-700 font-semibold">Audit queue</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-gray-200 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-gray-400 block mb-1">Active Gigs</span>
          <div className="text-xl font-bold text-blue-950 font-mono">{statistics?.activeJobs || 0}</div>
          <span className="text-[10px] text-gray-500">On-field dispatch</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-red-200 bg-red-50/20 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-red-700 block mb-1">Active SOS</span>
          <div className="text-xl font-bold text-red-800 font-mono">{sosAlerts.filter(s => s.status === 'ACTIVE').length}</div>
          <span className="text-[10px] text-red-600 font-semibold">Safety alerts</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-purple-200 bg-purple-50/20 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-purple-700 block mb-1">Open Disputes</span>
          <div className="text-xl font-bold text-purple-800 font-mono">{disputes.filter(d => d.status === 'OPEN').length}</div>
          <span className="text-[10px] text-purple-700 font-semibold">Arbitration desk</span>
        </div>

        <div className="bg-white p-3.5 rounded-xl border border-indigo-200 bg-indigo-50/20 shadow-xs">
          <span className="text-[10px] uppercase font-bold text-indigo-700 block mb-1">Welfare Pool (5%)</span>
          <div className="text-xl font-bold text-indigo-950 font-mono">₹{Math.round(welfareCorpus / 1000)}k</div>
          <span className="text-[10px] text-indigo-700 font-semibold">ESIC & Pension</span>
        </div>
      </div>

      {/* ── Main Navigation Tabs ── */}
      <div className="flex items-center gap-2 border-b border-gray-200 text-xs font-semibold overflow-x-auto">
        {[
          { key: 'LIVE_MAP', label: 'Live Worker & Demand Map' },
          { key: 'WORKERS', label: `Worker Verification (${workers.length})` },
          { key: 'BOOKINGS', label: `Dispatched Orders (${bookings.length})` },
          { key: 'DISPUTES', label: `Human Arbitration Desk (${disputes.length})` },
          { key: 'SOS_ALERTS', label: `SOS Emergency Feed (${sosAlerts.length})` },
          { key: 'SMART_AI', label: 'AI Demand Forecast & Mutual Aid' },
          { key: 'WELFARE', label: 'Welfare Corpus Live Ledger' },
        ].map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`pb-3 px-4 transition flex items-center gap-1.5 shrink-0 ${
              activeTab === tab.key
                ? 'text-blue-950 border-b-2 border-blue-950 font-bold'
                : 'text-gray-500 hover:text-gray-900 border-b-2 border-transparent'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* ─────────────────────────────────────────────────────────────
          TAB 1: LIVE WORKER & DEMAND MAP (PHASE 7)
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'LIVE_MAP' && (
        <div className="space-y-6">
          <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-bold text-base text-gray-900 flex items-center gap-2">
                  <MapPin className="text-blue-900" size={18} /> Regional Federation Real-Time Dispatch Map
                </h3>
                <p className="text-xs text-gray-500 mt-0.5">
                  Interactive tracking of active artisans, dispatch clusters, and emergency zones across Odisha districts.
                </p>
              </div>
              <div className="flex items-center gap-3 text-xs">
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-emerald-500"></span> Available ({liveMapData?.workers?.filter(w => w.availability === 'AVAILABLE').length || 0})</span>
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-amber-500"></span> On Job ({liveMapData?.workers?.filter(w => w.availability === 'BUSY').length || 0})</span>
                <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-ping"></span> SOS ({liveMapData?.workers?.filter(w => w.sos_active).length || 0})</span>
              </div>
            </div>

            {/* Visual Map Canvas Simulation */}
            <div className="h-80 bg-slate-900 rounded-2xl p-6 relative overflow-hidden flex flex-col justify-between border border-slate-800 text-white shadow-inner">
              <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#38bdf8_1px,transparent_1px)] [background-size:16px_16px]"></div>

              {/* Map clusters and markers */}
              <div className="relative z-10 flex justify-between items-start">
                <div className="bg-slate-800/80 backdrop-blur-sm p-3 rounded-xl border border-slate-700 text-xs space-y-1">
                  <div className="font-bold text-amber-400">Khordha District (Bhubaneswar Hub)</div>
                  <div className="text-slate-300">Active Artisans: 12 • Active Dispatches: 3</div>
                  <div className="text-[10px] text-emerald-400">Demand Heatmap Index: 94% (High)</div>
                </div>

                <div className="bg-slate-800/80 backdrop-blur-sm p-3 rounded-xl border border-slate-700 text-xs space-y-1">
                  <div className="font-bold text-sky-400">Cuttack District Society</div>
                  <div className="text-slate-300">Active Artisans: 6 • Surplus Capacity: +4</div>
                  <div className="text-[10px] text-sky-300">Mutual Aid Source Candidate</div>
                </div>

                <div className="bg-slate-800/80 backdrop-blur-sm p-3 rounded-xl border border-slate-700 text-xs space-y-1">
                  <div className="font-bold text-indigo-400">Puri Coastal Federation</div>
                  <div className="text-slate-300">Active Artisans: 4 • Tourism Load</div>
                  <div className="text-[10px] text-indigo-300">Demand Heatmap Index: 58%</div>
                </div>
              </div>

              {/* Center Map Grid Representation */}
              <div className="relative z-10 grid grid-cols-3 gap-4 text-center">
                {liveMapData?.heatmapClusters?.slice(0, 3).map((cluster, idx) => (
                  <div key={idx} className="p-3 bg-slate-800/90 rounded-xl border border-slate-700">
                    <span className="text-[10px] font-mono text-slate-400 uppercase">{cluster.name}</span>
                    <div className="text-sm font-bold text-white mt-0.5">{cluster.topTrade}</div>
                    <div className="text-[10px] text-amber-400 font-semibold mt-1">Density: {cluster.density} (Idx {cluster.demandIndex})</div>
                  </div>
                ))}
              </div>

              <div className="relative z-10 text-[10px] text-slate-400 flex items-center justify-between">
                <span>Coordinates Reference: 20.2961° N, 85.8245° E (Bhubaneswar Metro Hub)</span>
                <span className="text-emerald-400 font-mono">Live GPS Telemetry Sync: OK</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 2: WORKER ACCREDITATION & VERIFICATION DESK
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'WORKERS' && (
        <div className="space-y-4">
          {/* Header & Filter Controls */}
          <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-3 border-b border-gray-100">
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-wider px-2.5 py-0.5 rounded bg-blue-100 text-blue-900 border border-blue-200">
                  Odisha State Cooperative Societies Act, 1962
                </span>
                <h3 className="font-bold text-base text-gray-900 mt-1">
                  Worker Accreditation & Verification Queue
                </h3>
                <p className="text-xs text-gray-500 mt-0.5">
                  Review applicant trade skills, ITI/NSDC certificate numbers, and statutory KYC dossiers before approving state dispatch.
                </p>
              </div>

              {/* Status Counters */}
              <div className="flex items-center gap-2 flex-wrap">
                <button
                  type="button"
                  onClick={() => setWorkerStatusFilter('PENDING')}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 border ${
                    workerStatusFilter === 'PENDING'
                      ? 'bg-amber-500 text-slate-950 border-amber-500 shadow-xs'
                      : 'bg-amber-50 text-amber-900 border-amber-200 hover:bg-amber-100'
                  }`}
                >
                  <Clock size={13} />
                  <span>Pending ({workers.filter(w => w.verification_status === 'PENDING').length})</span>
                </button>

                <button
                  type="button"
                  onClick={() => setWorkerStatusFilter('VERIFIED')}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 border ${
                    workerStatusFilter === 'VERIFIED'
                      ? 'bg-emerald-700 text-white border-emerald-700 shadow-xs'
                      : 'bg-emerald-50 text-emerald-900 border-emerald-200 hover:bg-emerald-100'
                  }`}
                >
                  <CheckCircle2 size={13} />
                  <span>Verified ({workers.filter(w => w.verification_status === 'VERIFIED').length})</span>
                </button>

                <button
                  type="button"
                  onClick={() => setWorkerStatusFilter('REJECTED')}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 border ${
                    workerStatusFilter === 'REJECTED'
                      ? 'bg-red-700 text-white border-red-700 shadow-xs'
                      : 'bg-red-50 text-red-900 border-red-200 hover:bg-red-100'
                  }`}
                >
                  <XCircle size={13} />
                  <span>Rejected ({workers.filter(w => w.verification_status === 'REJECTED').length})</span>
                </button>

                <button
                  type="button"
                  onClick={() => setWorkerStatusFilter('ALL')}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition border ${
                    workerStatusFilter === 'ALL'
                      ? 'bg-slate-900 text-white border-slate-900 shadow-xs'
                      : 'bg-slate-100 text-slate-700 border-slate-200 hover:bg-slate-200'
                  }`}
                >
                  All ({workers.length})
                </button>
              </div>
            </div>

            {/* Search Input */}
            <div className="flex items-center gap-3">
              <div className="relative flex-1">
                <input
                  type="text"
                  placeholder="Search by artisan name, application ID, worker code, trade, district, or certificate no..."
                  value={workerSearch}
                  onChange={(e) => setWorkerSearch(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-gray-300 text-xs focus:outline-hidden focus:ring-2 focus:ring-blue-900"
                />
              </div>
            </div>

            {/* Applications Table */}
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-gray-50 text-gray-600 font-bold uppercase text-[10px] border-b">
                  <tr>
                    <th className="p-3">Applicant & Dossier ID</th>
                    <th className="p-3">Trade & Experience</th>
                    <th className="p-3">District & Federation</th>
                    <th className="p-3">Certifications (NCVT/ITI)</th>
                    <th className="p-3">Status</th>
                    <th className="p-3 text-right">Administrative Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {filteredWorkers.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="p-8 text-center text-gray-500">
                        No worker applications matching the selected filter.
                      </td>
                    </tr>
                  ) : (
                    filteredWorkers.map((w) => (
                      <tr key={w.id} className="hover:bg-gray-50/80 transition">
                        <td className="p-3">
                          <div className="font-bold text-gray-900 text-sm">{w.name}</div>
                          <div className="font-mono text-[10px] text-blue-900 font-bold">
                            {w.application_no || w.worker_code}
                          </div>
                          <div className="text-[11px] text-gray-500">{w.phone} • {w.email}</div>
                        </td>

                        <td className="p-3">
                          <span className="font-bold text-emerald-900 block">{w.primary_trade || 'General Artisan'}</span>
                          <span className="text-[11px] text-gray-600">{w.experience_years} yrs exp • {w.tier || 'BRONZE'}</span>
                          {w.sub_skills && (
                            <span className="text-[10px] text-slate-500 block truncate max-w-xs">{w.sub_skills}</span>
                          )}
                        </td>

                        <td className="p-3">
                          <span className="font-semibold text-gray-800 block">{w.district}</span>
                          <span className="text-[10px] text-gray-500">{w.cooperative_name || 'District Federation'}</span>
                        </td>

                        <td className="p-3">
                          {w.certifications && w.certifications.length > 0 ? (
                            <div className="space-y-0.5">
                              <span className="font-mono text-[11px] font-bold text-slate-800 block">
                                {w.certifications[0].certificate_number || 'CERT-RECORD'}
                              </span>
                              <span className="text-[10px] text-slate-500 block truncate max-w-[160px]">
                                {w.certifications[0].issuing_organization || 'Govt ITI / NCVT'}
                              </span>
                            </div>
                          ) : (
                            <span className="text-gray-400 text-[11px]">ITI / Skill Card Attached</span>
                          )}
                        </td>

                        <td className="p-3">
                          <span className={`px-2.5 py-1 rounded text-[10px] font-bold inline-flex items-center gap-1 ${
                            w.verification_status === 'VERIFIED'
                              ? 'bg-emerald-100 text-emerald-800 border border-emerald-200'
                              : w.verification_status === 'PENDING'
                              ? 'bg-amber-100 text-amber-800 border border-amber-200'
                              : 'bg-red-100 text-red-800 border border-red-200'
                          }`}>
                            {w.verification_status === 'VERIFIED' ? <CheckCircle2 size={11} /> : <Clock size={11} />}
                            {w.verification_status}
                          </span>
                        </td>

                        <td className="p-3 text-right">
                          <div className="flex items-center justify-end gap-1.5 flex-wrap">
                            <button
                              type="button"
                              onClick={() => setSelectedWorker(w)}
                              className="btn btn-secondary btn-sm text-[11px] py-1 px-2 text-blue-900 border-blue-200 hover:bg-blue-50"
                            >
                              <Eye size={12} /> View Dossier
                            </button>

                            {w.verification_status !== 'VERIFIED' ? (
                              <button
                                onClick={() => handleVerifyWorker(w.id, 'VERIFIED')}
                                disabled={actionBusyId === w.id}
                                className="btn btn-primary btn-sm text-[11px] py-1 px-2.5 bg-emerald-800 border-emerald-800 hover:bg-emerald-900"
                              >
                                {actionBusyId === w.id ? 'Saving...' : '✓ Approve'}
                              </button>
                            ) : (
                              <button
                                onClick={() => {
                                  const reason = window.prompt('Enter reason for revoking / rejecting accreditation:');
                                  if (reason) handleVerifyWorker(w.id, 'REJECTED', reason);
                                }}
                                disabled={actionBusyId === w.id}
                                className="btn btn-secondary btn-sm text-[11px] py-1 px-2 text-red-700 hover:bg-red-50"
                              >
                                Revoke
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 3: DISPUTES & HUMAN ARBITRATION DESK (PHASE 7)
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'DISPUTES' && (
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
          <div className="pb-3 border-b border-gray-100">
            <h3 className="font-bold text-base text-gray-900">Cooperative Human Dispute & Arbitration Desk</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Direct state arbitration for citizen and worker grievances with zero bot dead-ends.
            </p>
          </div>

          <div className="space-y-3">
            {disputes.length === 0 ? (
              <div className="text-center py-10 text-gray-500 text-xs">No active dispute tickets.</div>
            ) : (
              disputes.map((d) => (
                <div key={d.id} className="p-4 rounded-xl border border-gray-200 bg-gray-50/50 flex flex-col md:flex-row md:items-center justify-between gap-4 text-xs">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-blue-950">{d.ticket_code}</span>
                      <span className="px-2 py-0.5 rounded bg-blue-100 text-blue-950 font-bold text-[10px]">
                        {d.issue_type}
                      </span>
                      <span className={`px-2 py-0.5 rounded font-bold text-[10px] ${
                        d.status === 'RESOLVED' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                      }`}>
                        {d.status}
                      </span>
                    </div>
                    <p className="text-gray-800 font-medium">"{d.description}"</p>
                    <div className="text-[11px] text-gray-500">
                      Filed by: <strong>{d.customer_name}</strong> (Ph: {d.customer_phone}) • Artisan: {d.worker_name || 'Assigned Worker'}
                    </div>
                    {d.resolution_notes && (
                      <div className="p-2 bg-emerald-50 text-emerald-900 rounded-lg text-[11px] mt-1 border border-emerald-200">
                        <strong>Arbitration Outcome:</strong> {d.resolution_notes} (Arbitrator: {d.arbitrator_name})
                      </div>
                    )}
                  </div>

                  {d.status !== 'RESOLVED' && (
                    <button
                      onClick={() => setSelectedDispute(d)}
                      className="btn btn-primary btn-sm text-xs shrink-0"
                    >
                      Arbitrate & Resolve
                    </button>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 4: SOS ALERTS FEED (PHASE 4)
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'SOS_ALERTS' && (
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
          <div className="pb-3 border-b border-gray-100">
            <h3 className="font-bold text-base text-gray-900 flex items-center gap-2 text-red-700">
              <ShieldAlert size={18} /> Worker Emergency Safety & SOS Beacon Feeds
            </h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Live distress signals dispatched by on-field artisans with GPS telemetry.
            </p>
          </div>

          <div className="space-y-3">
            {sosAlerts.length === 0 ? (
              <div className="text-center py-10 text-gray-500 text-xs">No active emergency distress signals.</div>
            ) : (
              sosAlerts.map((alert) => (
                <div key={alert.id} className="p-4 rounded-xl border border-red-200 bg-red-50/50 flex items-center justify-between gap-4 text-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-red-700">🚨 EMERGENCY DISTRESS SIGNAL</span>
                      <span className="font-mono text-gray-600">{alert.worker_code}</span>
                    </div>
                    <div className="text-sm font-bold text-gray-900 mt-1">{alert.worker_name} ({alert.worker_district})</div>
                    <p className="text-gray-600 text-[11px] mt-0.5">Phone: <strong>{alert.worker_phone}</strong> • Details: {alert.details}</p>
                    <span className="text-[10px] text-gray-400">Triggered at: {alert.triggered_at}</span>
                  </div>
                  <button className="btn btn-primary btn-sm text-xs bg-red-700 hover:bg-red-800">
                    Dispatch Patrol
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 5: WELFARE CORPUS LIVE LEDGER (PHASE 5 & 7)
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'WELFARE' && (
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-6">
          <div className="pb-3 border-b border-gray-100">
            <h3 className="font-bold text-base text-gray-900">5% Cooperative Welfare Fund Corpus Live Ledger</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Transparent pooling and disbursement ledger for ESIC accident insurance, pensions, and medical emergency grants.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-200">
              <span className="text-xs font-bold text-emerald-900 block">Total Pooled Levy Corpus</span>
              <div className="text-2xl font-bold font-mono text-emerald-950 mt-1">₹{welfareCorpus.toLocaleString('en-IN')}</div>
              <span className="text-[10px] text-emerald-700">5% automatically deducted from every order</span>
            </div>

            <div className="p-4 bg-blue-50 rounded-xl border border-blue-200">
              <span className="text-xs font-bold text-blue-900 block">Active ESIC Insured Artisans</span>
              <div className="text-2xl font-bold font-mono text-blue-950 mt-1">{statistics?.verifiedWorkers || 18} Artisans</div>
              <span className="text-[10px] text-blue-700">₹2,00,000 policy coverage each</span>
            </div>

            <div className="p-4 bg-purple-50 rounded-xl border border-purple-200">
              <span className="text-xs font-bold text-purple-900 block">EPFO Retirement Reserve</span>
              <div className="text-2xl font-bold font-mono text-purple-950 mt-1">₹{Math.round(welfareCorpus * 0.4).toLocaleString('en-IN')}</div>
              <span className="text-[10px] text-purple-700">Monthly federation contribution</span>
            </div>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 6: SMART AI FORECAST & MUTUAL AID
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'SMART_AI' && (
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-6">
          <div className="pb-3 border-b border-gray-100">
            <h3 className="font-bold text-base text-gray-900">AI Seasonal Demand Projections & Mutual Aid Matrix</h3>
            <p className="text-xs text-gray-500 mt-0.5">
              Predictive spikes and inter-cooperative temporary workforce balance.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {forecastData?.seasonalSpikes?.map((spike, idx) => (
              <div key={idx} className="p-4 rounded-xl border border-gray-200 bg-gray-50/60 text-xs space-y-1">
                <div className="flex items-center justify-between font-bold text-gray-900">
                  <span>{spike.season}</span>
                  <span className="text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200 font-mono">
                    {spike.surgeMultiplier}
                  </span>
                </div>
                <div className="text-blue-900 font-semibold">{spike.trade}</div>
                <p className="text-gray-500 text-[11px]">{spike.recommendedAction}</p>
              </div>
            ))}
          </div>

          {/* Mutual Aid Proposals */}
          <div className="pt-4 border-t border-gray-100">
            <h4 className="font-bold text-sm text-gray-900 mb-3">Inter-District Mutual Aid Dispatch Approvals</h4>
            <div className="space-y-3">
              {allocationData?.mutualAidProposals?.map((prop) => (
                <div key={prop.proposalId} className="p-4 rounded-xl border border-indigo-200 bg-indigo-50/30 flex items-center justify-between text-xs">
                  <div>
                    <div className="font-bold text-indigo-950">{prop.trade} Transfer: {prop.sourceCoop} ➔ {prop.targetCoop}</div>
                    <p className="text-gray-600 mt-0.5">{prop.recommendedTransferCount} workers requested • Reason: {prop.reason}</p>
                  </div>
                  <button
                    onClick={() => handleApproveMutualAid(prop.proposalId)}
                    disabled={mutualAidBusyId === prop.proposalId}
                    className="btn btn-primary btn-sm text-xs font-bold"
                  >
                    Authorize Dispatch Transfer
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 7: BOOKINGS OVERSIGHT
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'BOOKINGS' && (
        <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-gray-100">
            <h3 className="font-bold text-base text-gray-900">All Federation Service Bookings</h3>
            <select
              value={bookingStatusFilter}
              onChange={(e) => setBookingStatusFilter(e.target.value)}
              className="px-3 py-1.5 rounded-lg border border-gray-300 text-xs bg-white"
            >
              <option value="ALL">All Statuses</option>
              <option value="REQUESTED">Requested</option>
              <option value="MATCHED">Matched</option>
              <option value="ACCEPTED">Accepted</option>
              <option value="IN_PROGRESS">In Progress</option>
              <option value="COMPLETED">Completed</option>
            </select>
          </div>

          <div className="divide-y divide-gray-100 text-xs">
            {filteredBookings.map((b) => (
              <div key={b.id} className="py-3 flex items-center justify-between">
                <div>
                  <span className="font-mono font-bold text-blue-900">{b.booking_code}</span>
                  <div className="font-bold text-gray-900">{b.service_name}</div>
                  <div className="text-gray-500">{b.customer_name} • {b.location_district} • {b.scheduled_date}</div>
                </div>
                <div className="text-right">
                  <span className="font-mono font-bold text-gray-900 text-sm">₹{b.total_amount}</span>
                  <span className="block text-[10px] font-bold text-blue-900 uppercase">{b.status}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Dispute Resolution Modal */}
      {selectedDispute && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-bold text-sm text-blue-950">Arbitrate Dispute: {selectedDispute.ticket_code}</h3>
              <button onClick={() => setSelectedDispute(null)}><X size={16} /></button>
            </div>

            <div className="text-xs text-gray-700 bg-gray-50 p-3 rounded-xl space-y-1">
              <div><strong>Issue:</strong> {selectedDispute.issue_type}</div>
              <div><strong>Description:</strong> "{selectedDispute.description}"</div>
              <div><strong>Citizen:</strong> {selectedDispute.customer_name} (Ph: {selectedDispute.customer_phone})</div>
            </div>

            <form onSubmit={handleResolveDispute} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1">Arbitration & Settlement Notes</label>
                <textarea
                  rows={3}
                  required
                  placeholder="Enter resolution details, agreed adjustments, or supervisor notes..."
                  value={resolutionNotes}
                  onChange={(e) => setResolutionNotes(e.target.value)}
                  className="w-full p-2.5 rounded-xl border border-gray-300 text-xs focus:ring-2 focus:ring-blue-900"
                />
              </div>

              <div className="flex justify-end gap-2">
                <button type="button" onClick={() => setSelectedDispute(null)} className="btn btn-secondary btn-sm">Cancel</button>
                <button type="submit" disabled={resolvingDispute} className="btn btn-primary btn-sm">
                  {resolvingDispute ? 'Saving...' : 'Finalize Resolution'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── WORKER ACCREDITATION DOSSIER MODAL ── */}
      {selectedWorker && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 md:p-8 shadow-2xl space-y-5 my-8">
            {/* Modal Header */}
            <div className="flex items-center justify-between border-b border-gray-200 pb-3">
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-widest px-2.5 py-0.5 rounded bg-blue-100 text-blue-900 border border-blue-200">
                  Government Worker Accreditation Dossier
                </span>
                <h3 className="font-bold text-lg text-slate-900 mt-1">
                  {selectedWorker.name}
                </h3>
                <span className="font-mono text-xs text-slate-500 font-bold">
                  App Ref: {selectedWorker.application_no || selectedWorker.worker_code}
                </span>
              </div>
              <button
                onClick={() => setSelectedWorker(null)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100"
              >
                <X size={20} />
              </button>
            </div>

            {/* Status Alert in Modal */}
            <div className={`p-3 rounded-xl border text-xs flex items-center justify-between ${
              selectedWorker.verification_status === 'VERIFIED'
                ? 'bg-emerald-50 border-emerald-200 text-emerald-900'
                : selectedWorker.verification_status === 'PENDING'
                ? 'bg-amber-50 border-amber-200 text-amber-900'
                : 'bg-red-50 border-red-200 text-red-900'
            }`}>
              <div className="flex items-center gap-2">
                {selectedWorker.verification_status === 'VERIFIED' ? <CheckCircle2 size={16} /> : <Clock size={16} />}
                <strong>Accreditation Status: {selectedWorker.verification_status}</strong>
              </div>
              <span className="text-[11px] font-semibold">{selectedWorker.cooperative_name || 'District Federation'}</span>
            </div>

            {/* Dossier Body */}
            <div className="space-y-4 text-xs">
              {/* 1. Identity & Personal Details */}
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                <strong className="text-blue-950 font-bold uppercase text-[10px] tracking-wider block">
                  1. Personal & Residential Information
                </strong>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 text-slate-700">
                  <div><span className="text-slate-400 block text-[10px]">Mobile:</span> {selectedWorker.phone || 'N/A'}</div>
                  <div><span className="text-slate-400 block text-[10px]">Email:</span> {selectedWorker.email || 'N/A'}</div>
                  <div><span className="text-slate-400 block text-[10px]">District:</span> {selectedWorker.district}</div>
                  <div><span className="text-slate-400 block text-[10px]">City:</span> {selectedWorker.city || 'Bhubaneswar'}</div>
                  <div><span className="text-slate-400 block text-[10px]">Pincode:</span> {selectedWorker.pincode || '751024'}</div>
                  <div className="col-span-2 sm:col-span-3"><span className="text-slate-400 block text-[10px]">Address:</span> {selectedWorker.address || 'Registered local address'}</div>
                </div>
              </div>

              {/* 2. Trade & Tooling Details */}
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                <strong className="text-emerald-950 font-bold uppercase text-[10px] tracking-wider block">
                  2. Trade Skills & Equipment
                </strong>
                <div className="grid grid-cols-2 gap-2 text-slate-700">
                  <div><span className="text-slate-400 block text-[10px]">Primary Trade:</span> <strong className="text-slate-900">{selectedWorker.primary_trade || 'General Artisan'}</strong></div>
                  <div><span className="text-slate-400 block text-[10px]">Experience:</span> {selectedWorker.experience_years} Years ({selectedWorker.tier || 'BRONZE'})</div>
                  <div className="col-span-2"><span className="text-slate-400 block text-[10px]">Sub-Skills:</span> {selectedWorker.sub_skills || 'General maintenance & diagnostic repair'}</div>
                  <div className="col-span-2"><span className="text-slate-400 block text-[10px]">Tools Owned:</span> {selectedWorker.tools_owned || 'Standard professional tooling & safety helmet'}</div>
                </div>
              </div>

              {/* 3. Trade Certifications */}
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                <strong className="text-amber-950 font-bold uppercase text-[10px] tracking-wider block">
                  3. Trade Certifications (NCVT / ITI / NSDC)
                </strong>
                {selectedWorker.certifications && selectedWorker.certifications.length > 0 ? (
                  selectedWorker.certifications.map((cert, cIdx) => (
                    <div key={cIdx} className="p-2.5 bg-white rounded-lg border border-slate-200 flex items-center justify-between">
                      <div>
                        <div className="font-bold text-slate-900">{cert.certification_name || 'Trade Certificate'}</div>
                        <div className="text-[11px] text-slate-500 font-mono">Reg No: {cert.certificate_number}</div>
                        <div className="text-[10px] text-slate-400">{cert.issuing_organization} • Issued: {cert.issue_date}</div>
                      </div>
                      <span className="gov-seal-verified">
                        {cert.verification_status}
                      </span>
                    </div>
                  ))
                ) : (
                  <div className="text-slate-500 italic">ITI / NSDC Certificate attached in physical file.</div>
                )}
              </div>

              {/* 4. Statutory KYC & Banking */}
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                <strong className="text-indigo-950 font-bold uppercase text-[10px] tracking-wider block">
                  4. Statutory KYC & Bank Account (Direct 90% Pay)
                </strong>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2 text-slate-700">
                  <div><span className="text-slate-400 block text-[10px]">Aadhaar (Masked):</span> <span className="font-mono">{selectedWorker.aadhaar_number ? `XXXX-XXXX-${selectedWorker.aadhaar_number.slice(-4)}` : 'Verified on File'}</span></div>
                  <div><span className="text-slate-400 block text-[10px]">PAN Card:</span> <span className="font-mono font-bold">{selectedWorker.pan_number || 'Verified'}</span></div>
                  <div><span className="text-slate-400 block text-[10px]">Ration / BPL:</span> <span className="font-mono">{selectedWorker.ration_card || 'N/A'}</span></div>
                  <div><span className="text-slate-400 block text-[10px]">Bank Name:</span> {selectedWorker.bank_name || 'State Bank of India'}</div>
                  <div><span className="text-slate-400 block text-[10px]">Account No:</span> <span className="font-mono font-bold">{selectedWorker.bank_account ? `••••${selectedWorker.bank_account.slice(-4)}` : '••••8821'}</span></div>
                  <div><span className="text-slate-400 block text-[10px]">IFSC Code:</span> <span className="font-mono font-bold">{selectedWorker.bank_ifsc || 'SBIN0001234'}</span></div>
                  <div className="col-span-2 sm:col-span-3 border-t border-slate-200 pt-1.5 mt-1">
                    <span className="text-slate-400 block text-[10px]">Emergency Contact:</span>
                    <strong>{selectedWorker.emergency_contact_name || 'Nominee'}</strong> ({selectedWorker.emergency_contact_relation || 'Family'}) • Ph: {selectedWorker.emergency_contact_phone || '9876500000'}
                  </div>
                </div>
              </div>
            </div>

            {/* Action Buttons in Modal */}
            <div className="border-t border-gray-200 pt-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <button
                type="button"
                onClick={() => setSelectedWorker(null)}
                className="btn btn-secondary btn-sm"
              >
                Close Dossier
              </button>

              <div className="flex items-center gap-2 flex-wrap">
                {selectedWorker.verification_status !== 'VERIFIED' ? (
                  <>
                    <button
                      type="button"
                      onClick={() => {
                        const reason = window.prompt('Enter reason for rejection / return:');
                        if (reason) {
                          handleVerifyWorker(selectedWorker.id, 'REJECTED', reason);
                        }
                      }}
                      disabled={actionBusyId === selectedWorker.id}
                      className="btn btn-secondary btn-sm text-red-700 border-red-200 hover:bg-red-50"
                    >
                      ✗ Reject Application
                    </button>

                    <button
                      type="button"
                      onClick={() => handleVerifyWorker(selectedWorker.id, 'VERIFIED')}
                      disabled={actionBusyId === selectedWorker.id}
                      className="btn btn-primary btn-sm bg-emerald-800 border-emerald-800 hover:bg-emerald-900 font-bold"
                    >
                      {actionBusyId === selectedWorker.id ? 'Accrediting...' : '✓ Approve & Issue State Accreditation'}
                    </button>
                  </>
                ) : (
                  <button
                    type="button"
                    onClick={() => {
                      const reason = window.prompt('Enter reason for revoking accreditation:');
                      if (reason) handleVerifyWorker(selectedWorker.id, 'REJECTED', reason);
                    }}
                    disabled={actionBusyId === selectedWorker.id}
                    className="btn btn-secondary btn-sm text-red-700"
                  >
                    Revoke Accreditation
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
