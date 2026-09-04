import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { useAuth } from '../context/AuthContext';
import {
  Building2, Users, ShieldAlert, DollarSign, Award, GraduationCap,
  Landmark, AlertCircle, CheckCircle2, TrendingUp, HeartHandshake,
  FileText, Plus, Search, ChevronRight, ArrowRight, ShieldCheck,
  Briefcase, Wrench, Clock, Activity, AlertTriangle, FileSpreadsheet
} from 'lucide-react';

export default function FederationPortal() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [activeConsole, setActiveConsole] = useState('ADMIN'); // 'ADMIN' or 'TREASURER'

  // Admin Desk Slide: 1 = Workforce Telemetry, 2 = Disputes & Grievances, 3 = Accreditation & KYC
  const [adminSlide, setAdminSlide] = useState(1);

  // Data States
  const [adminData, setAdminData] = useState(null);
  const [treasurerData, setTreasurerData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Worker Register Modal under Federation (Page 2)
  const [showWorkerModal, setShowWorkerModal] = useState(false);
  const [workerFormData, setWorkerFormData] = useState({
    name: '',
    email: '',
    phone: '',
    password: 'demoPassword123',
    primaryTrade: 'Electrical',
    experienceYears: 3,
    district: 'Khordha',
    city: 'Bhubaneswar',
    isNcctCertified: false,
  });
  const [registeringWorker, setRegisteringWorker] = useState(false);

  // NCCT Course Application Modal (Page 3)
  const [showNcctModal, setShowNcctModal] = useState(false);
  const [ncctFormData, setNcctFormData] = useState({
    workerName: '',
    trade: 'Electrical',
    courseName: 'Advanced Solar Inverter & Smart Grid Architecture',
    trainingType: 'TECHNICAL',
  });
  const [applyingNcct, setApplyingNcct] = useState(false);

  const fetchPortalData = async () => {
    setLoading(true);
    try {
      const [adminRes, treasRes] = await Promise.all([
        api.getFederationAdminDashboard(1),
        api.getFederationTreasurerDashboard(1),
      ]);
      if (adminRes.success) setAdminData(adminRes.data);
      if (treasRes.success) setTreasurerData(treasRes.data);
    } catch (err) {
      console.error('Failed to load Federation Portal data:', err);
      setError(err.message || 'Failed to load federation data.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user && user.role === 'WORKER') {
      navigate('/worker/dashboard', { replace: true });
      return;
    }
    if (user && user.role === 'CUSTOMER') {
      navigate('/customer/bookings', { replace: true });
      return;
    }
    fetchPortalData();
  }, [user]);

  // Handle Onboard Worker under Federation
  const handleRegisterWorker = async (e) => {
    e.preventDefault();
    setRegisteringWorker(true);
    setError('');
    try {
      const res = await api.registerWorkerByFederation({
        ...workerFormData,
        societyId: 1,
      });
      if (res.success) {
        setShowWorkerModal(false);
        setWorkerFormData({
          name: '',
          email: '',
          phone: '',
          password: 'demoPassword123',
          primaryTrade: 'Electrical',
          experienceYears: 3,
          district: 'Khordha',
          city: 'Bhubaneswar',
          isNcctCertified: false,
        });
        fetchPortalData();
      }
    } catch (err) {
      setError(err.message || 'Failed to register worker under federation.');
    } finally {
      setRegisteringWorker(false);
    }
  };

  // Handle NCCT Training Application
  const handleApplyNcct = async (e) => {
    e.preventDefault();
    setApplyingNcct(true);
    setError('');
    try {
      const res = await api.applyNcctTraining({
        ...ncctFormData,
        societyId: 1,
      });
      if (res.success) {
        setShowNcctModal(false);
        fetchPortalData();
      }
    } catch (err) {
      setError(err.message || 'Failed to apply for NCCT training.');
    } finally {
      setApplyingNcct(false);
    }
  };

  if (loading) {
    return (
      <div className="container py-16 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-2"></div>
        <p className="text-xs text-gray-500">Loading Federation Operational Desks...</p>
      </div>
    );
  }

  const kpis = treasurerData?.kpis || {};
  const society = treasurerData?.society || {};

  return (
    <div className="container py-8 max-w-6xl mx-auto space-y-6">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-blue-950 via-slate-900 to-indigo-950 rounded-2xl p-6 md:p-8 text-white shadow-md space-y-3 relative overflow-hidden">
        <div className="relative z-10 space-y-2">
          <div className="flex flex-wrap items-center gap-2">
            <span className="px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-200 text-xs font-bold uppercase tracking-wider flex items-center gap-1.5">
              <Building2 size={14} className="text-amber-400" />
              National Cooperative Federation Console
            </span>
            <span className="px-3 py-1 rounded-full bg-amber-400/20 border border-amber-400/40 text-amber-300 text-xs font-bold">
              🌟 NLCF Affiliated • Trusted Federation
            </span>
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-white">
            {society.name || 'Shramik Kalyan National Labour Cooperative Samiti'}
          </h1>
          <p className="text-xs md:text-sm text-blue-200 max-w-3xl">
            Multi-role governance console for Federation <strong>Administrators</strong> (Workforce Telemetry & 30-Day Guarantee Disputes) and <strong>Treasurers</strong> (10 Financial KPIs, Welfare Funds & Loan Accounting).
          </p>
        </div>

        {/* Console Switcher (Admin vs Treasurer) */}
        <div className="mt-6 flex flex-wrap items-center justify-between gap-3 relative z-10 border-t border-blue-800/60 pt-4">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setActiveConsole('ADMIN')}
              className={`px-5 py-2.5 rounded-xl text-xs font-extrabold transition flex items-center gap-2 ${
                activeConsole === 'ADMIN'
                  ? 'bg-blue-600 text-white shadow-md ring-2 ring-blue-400'
                  : 'bg-blue-900/50 text-blue-200 hover:bg-blue-800'
              }`}
            >
              <Users size={16} /> 🛠️ Admin Console
            </button>
            <button
              onClick={() => setActiveConsole('TREASURER')}
              className={`px-5 py-2.5 rounded-xl text-xs font-extrabold transition flex items-center gap-2 ${
                activeConsole === 'TREASURER'
                  ? 'bg-emerald-600 text-white shadow-md ring-2 ring-emerald-400'
                  : 'bg-blue-900/50 text-blue-200 hover:bg-blue-800'
              }`}
            >
              <DollarSign size={16} /> 💰 Treasurer Console (10 KPIs)
            </button>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowWorkerModal(true)}
              className="px-3.5 py-2 rounded-xl text-xs font-bold bg-amber-400 text-blue-950 hover:bg-amber-300 transition flex items-center gap-1.5 shadow-sm"
            >
              <Plus size={14} /> Onboard Worker
            </button>
            <button
              onClick={() => setShowNcctModal(true)}
              className="px-3.5 py-2 rounded-xl text-xs font-bold bg-purple-600 text-white hover:bg-purple-500 transition flex items-center gap-1.5 shadow-sm"
            >
              <GraduationCap size={14} /> Apply NCCT Training
            </button>
          </div>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-xs flex items-start gap-2">
          <AlertCircle size={16} className="shrink-0 mt-0.5 text-red-600" />
          <div>{error}</div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          CONSOLE 1: FEDERATION ADMIN DESK (PAGE 4: 3 SLIDES)
         ───────────────────────────────────────────────────────────── */}
      {activeConsole === 'ADMIN' && adminData && (
        <div className="space-y-6">
          {/* Slide Navigation Tabs */}
          <div className="flex items-center gap-2 border-b border-gray-200 pb-2">
            <button
              onClick={() => setAdminSlide(1)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 ${
                adminSlide === 1
                  ? 'bg-blue-900 text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <Activity size={14} /> Workforce Live Telemetry
            </button>
            <button
              onClick={() => setAdminSlide(2)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 ${
                adminSlide === 2
                  ? 'bg-blue-900 text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <ShieldAlert size={14} /> Disputes & 30-Day Guarantee Desk
            </button>
            <button
              onClick={() => setAdminSlide(3)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 ${
                adminSlide === 3
                  ? 'bg-blue-900 text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <Award size={14} /> NCCT Accreditation & KYC Queue
            </button>
          </div>

          {/* SLIDE 1: WORKFORCE LIVE TELEMETRY (PAGE 4) */}
          {adminSlide === 1 && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="p-5 rounded-2xl bg-blue-50 border border-blue-200 space-y-1">
                  <span className="text-[11px] font-bold text-blue-900 uppercase tracking-wider">1. Total Workers</span>
                  <div className="text-2xl font-extrabold text-blue-950 font-mono">
                    {adminData.slide1_workforce.totalWorkers}
                  </div>
                  <p className="text-[11px] text-blue-800 font-medium">Registered federation artisans</p>
                </div>

                <div className="p-5 rounded-2xl bg-emerald-50 border border-emerald-200 space-y-1">
                  <span className="text-[11px] font-bold text-emerald-900 uppercase tracking-wider flex items-center gap-1.5">
                    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                    2. Active Workers on Site
                  </span>
                  <div className="text-2xl font-extrabold text-emerald-950 font-mono">
                    {adminData.slide1_workforce.activeWorkersOnSite}
                  </div>
                  <p className="text-[11px] text-emerald-800 font-medium">Executing live client sessions</p>
                </div>

                <div className="p-5 rounded-2xl bg-amber-50 border border-amber-200 space-y-1">
                  <span className="text-[11px] font-bold text-amber-900 uppercase tracking-wider">4. Free / Available Workers</span>
                  <div className="text-2xl font-extrabold text-amber-950 font-mono">
                    {adminData.slide1_workforce.freeWorkers}
                  </div>
                  <p className="text-[11px] text-amber-800 font-medium">Ready for immediate dispatch</p>
                </div>

                <div className="p-5 rounded-2xl bg-gray-50 border border-gray-200 space-y-1">
                  <span className="text-[11px] font-bold text-gray-700 uppercase tracking-wider">3. Offline / Leave Workers</span>
                  <div className="text-2xl font-extrabold text-gray-900 font-mono">
                    {adminData.slide1_workforce.offlineWorkers}
                  </div>
                  <p className="text-[11px] text-gray-600 font-medium">Off duty or scheduled leave</p>
                </div>
              </div>

              {/* Workers Master Roster with Dynamic Tiers */}
              <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-xs space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider">
                      Federation Registered Workers Roster & Dynamic Tiers
                    </h3>
                    <p className="text-xs text-gray-500">
                      Tiers auto-calculated based on NLCF Affiliation, NCCT Training, and Experience years.
                    </p>
                  </div>
                  <span className="text-xs font-bold text-blue-900 bg-blue-50 px-2.5 py-1 rounded-lg border border-blue-200">
                    NLCF Status: Trusted Federation
                  </span>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs border-collapse">
                    <thead className="bg-gray-50 text-gray-700 border-b border-gray-200 text-[10px] uppercase font-semibold">
                      <tr>
                        <th className="p-3">Artisan</th>
                        <th className="p-3">Trade</th>
                        <th className="p-3">Experience</th>
                        <th className="p-3">NCCT Certified</th>
                        <th className="p-3">Calculated Tier</th>
                        <th className="p-3">Federation Badge</th>
                        <th className="p-3">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 text-gray-700">
                      {adminData.workersList.slice(0, 10).map((w) => (
                        <tr key={w.id} className="hover:bg-blue-50/40">
                          <td className="p-3">
                            <strong className="text-gray-900 block">{w.user_name || w.name}</strong>
                            <span className="text-[10px] text-gray-400 font-mono">{w.worker_code}</span>
                          </td>
                          <td className="p-3 font-semibold text-blue-950">{w.primary_trade || 'Multi-Trade'}</td>
                          <td className="p-3 font-mono">{w.experience_years} Years</td>
                          <td className="p-3">
                            {w.isNcctCertified ? (
                              <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-purple-100 text-purple-900 flex items-center gap-1 w-max">
                                <GraduationCap size={12} /> NCCT Certified
                              </span>
                            ) : (
                              <span className="text-gray-400 text-[11px]">—</span>
                            )}
                          </td>
                          <td className="p-3">
                            <span className={`px-2 py-0.5 rounded text-[10px] font-extrabold ${
                              w.computedTier === 'MASTER' ? 'bg-amber-400 text-blue-950 ring-1 ring-amber-500' :
                              w.computedTier === 'GOLD' ? 'bg-amber-100 text-amber-900 border border-amber-300' :
                              w.computedTier === 'SILVER' ? 'bg-slate-200 text-slate-900' : 'bg-orange-100 text-orange-900'
                            }`}>
                              {w.computedTier}
                            </span>
                          </td>
                          <td className="p-3">
                            <span className="text-[11px] font-bold text-blue-900">
                              {w.badgeLabel}
                            </span>
                          </td>
                          <td className="p-3">
                            <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                              w.availability === 'AVAILABLE' ? 'bg-emerald-100 text-emerald-800' :
                              w.availability === 'BUSY' ? 'bg-amber-100 text-amber-800' : 'bg-gray-100 text-gray-600'
                            }`}>
                              {w.availability}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* SLIDE 2: DISPUTES & 30-DAY GUARANTEE DESK (PAGE 4) */}
          {adminSlide === 2 && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                <div className="p-5 rounded-2xl bg-blue-50 border border-blue-200 space-y-1">
                  <span className="text-[11px] font-bold text-blue-900 uppercase tracking-wider">1. Total Issues Reported</span>
                  <div className="text-2xl font-extrabold text-blue-950 font-mono">
                    {adminData.slide2_disputes.totalIssues}
                  </div>
                  <p className="text-[11px] text-blue-800">Total customer service disputes</p>
                </div>

                <div className="p-5 rounded-2xl bg-emerald-50 border border-emerald-200 space-y-1">
                  <span className="text-[11px] font-bold text-emerald-900 uppercase tracking-wider">2. Resolved Issues</span>
                  <div className="text-2xl font-extrabold text-emerald-950 font-mono">
                    {adminData.slide2_disputes.resolvedIssues}
                  </div>
                  <p className="text-[11px] text-emerald-800">Arbitrated and closed by DCO desk</p>
                </div>

                <div className="p-5 rounded-2xl bg-amber-50 border border-amber-200 space-y-1">
                  <span className="text-[11px] font-bold text-amber-900 uppercase tracking-wider">3. Unresolved / Open Issues</span>
                  <div className="text-2xl font-extrabold text-amber-950 font-mono">
                    {adminData.slide2_disputes.unresolvedIssues}
                  </div>
                  <p className="text-[11px] text-amber-800">Under active dispute mediation</p>
                </div>

                <div className="p-5 rounded-2xl bg-purple-50 border border-purple-200 space-y-1">
                  <span className="text-[11px] font-bold text-purple-900 uppercase tracking-wider">4. 30-Day Guarantee Resolved Cases</span>
                  <div className="text-2xl font-extrabold text-purple-950 font-mono">
                    {adminData.slide2_disputes.sevenDayPolicyResolved}
                  </div>
                  <p className="text-[11px] text-purple-800">₹0 Master re-dispatch executed successfully</p>
                </div>

                <div className="p-5 rounded-2xl bg-rose-50 border border-rose-200 space-y-1">
                  <span className="text-[11px] font-bold text-rose-900 uppercase tracking-wider">5. 30-Day Policy Unresolved Cases</span>
                  <div className="text-2xl font-extrabold text-rose-950 font-mono">
                    {adminData.slide2_disputes.sevenDayPolicyUnresolved}
                  </div>
                  <p className="text-[11px] text-rose-800">Pending secondary warranty inspection</p>
                </div>

                <div className="p-5 rounded-2xl bg-indigo-50 border border-indigo-200 space-y-1">
                  <span className="text-[11px] font-bold text-indigo-900 uppercase tracking-wider">6. Worker Grievances & Appeals</span>
                  <div className="text-2xl font-extrabold text-indigo-950 font-mono">
                    {adminData.slide2_disputes.workerIssues}
                  </div>
                  <p className="text-[11px] text-indigo-800">Internal welfare & payment queries</p>
                </div>
              </div>
            </div>
          )}

          {/* SLIDE 3: ACCREDITATION & TRAINING QUEUE (PAGE 4) */}
          {adminSlide === 3 && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="p-6 rounded-2xl bg-purple-50 border border-purple-200 flex items-center justify-between">
                  <div className="space-y-1">
                    <span className="text-xs font-bold text-purple-900 uppercase tracking-wider">1. NCCT Trained Workers</span>
                    <div className="text-3xl font-extrabold text-purple-950 font-mono">
                      {adminData.slide3_accreditation.ncctTrainedWorkers}
                    </div>
                    <p className="text-xs text-purple-800">Accredited by National Council for Cooperative Training</p>
                  </div>
                  <GraduationCap size={44} className="text-purple-400 shrink-0" />
                </div>

                <div className="p-6 rounded-2xl bg-amber-50 border border-amber-200 flex items-center justify-between">
                  <div className="space-y-1">
                    <span className="text-xs font-bold text-amber-900 uppercase tracking-wider">2. KYC Pending Approvals</span>
                    <div className="text-3xl font-extrabold text-amber-950 font-mono">
                      {adminData.slide3_accreditation.kycPendingWorkers}
                    </div>
                    <p className="text-xs text-amber-800">Artisans awaiting Aadhaar & trade license verification</p>
                  </div>
                  <FileText size={44} className="text-amber-400 shrink-0" />
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          CONSOLE 2: FEDERATION TREASURER DESK (PAGE 4: 10 KPIS)
         ───────────────────────────────────────────────────────────── */}
      {activeConsole === 'TREASURER' && (
        <div className="space-y-6">
          <div className="border-b border-gray-100 pb-3 flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold text-emerald-900 uppercase tracking-wider">
                Treasurer Console • Statutory Financial Ledger
              </span>
              <h2 className="text-lg font-bold text-gray-900">
                10 Core Financial, Welfare & Project Treasury KPIs
              </h2>
            </div>
            <span className="text-xs font-bold bg-emerald-100 text-emerald-900 px-3 py-1 rounded-full">
              Bylaws Compliance: 93-2-5 Split Audited
            </span>
          </div>

          {/* 10 Specific KPIs Grid (Specification Page 4) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {/* KPI 1: Total Amount in Account */}
            <div className="p-4 rounded-2xl bg-emerald-50 border-2 border-emerald-400 space-y-1">
              <span className="text-[10px] font-bold text-emerald-900 uppercase tracking-wider">
                1. Total Amount in Account
              </span>
              <div className="text-xl font-extrabold text-emerald-950 font-mono">
                ₹{kpis.totalAmountInAccount?.toLocaleString()}
              </div>
              <p className="text-[10px] text-emerald-800 font-medium">Verified treasury balance</p>
            </div>

            {/* KPI 2: Total Health Insurances */}
            <div className="p-4 rounded-2xl bg-blue-50 border border-blue-200 space-y-1">
              <span className="text-[10px] font-bold text-blue-900 uppercase tracking-wider">
                2. Health Insurances Registered
              </span>
              <div className="text-xl font-extrabold text-blue-950 font-mono">
                {kpis.totalHealthInsurancesRegistered}
              </div>
              <p className="text-[10px] text-blue-800 font-medium">Active ESIC worker policies</p>
            </div>

            {/* KPI 3: Accident Policies Active */}
            <div className="p-4 rounded-2xl bg-purple-50 border border-purple-200 space-y-1">
              <span className="text-[10px] font-bold text-purple-900 uppercase tracking-wider">
                3. Accident Policies Active
              </span>
              <div className="text-xl font-extrabold text-purple-950 font-mono">
                {kpis.accidentPoliciesActive}
              </div>
              <p className="text-[10px] text-purple-800 font-medium">₹5,00,000 accidental cover</p>
            </div>

            {/* KPI 4: Cancellation Revenue */}
            <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 space-y-1">
              <span className="text-[10px] font-bold text-rose-900 uppercase tracking-wider">
                4. Revenues via Cancellations
              </span>
              <div className="text-xl font-extrabold text-rose-950 font-mono">
                ₹{kpis.revenuesThroughCancellations?.toLocaleString()}
              </div>
              <p className="text-[10px] text-rose-800 font-medium">Cooperative late forfeit pool</p>
            </div>

            {/* KPI 5: Revenues through 2% Platform Fees */}
            <div className="p-4 rounded-2xl bg-indigo-50 border border-indigo-200 space-y-1">
              <span className="text-[10px] font-bold text-indigo-900 uppercase tracking-wider">
                5. Revenues via 2% Platform Fee
              </span>
              <div className="text-xl font-extrabold text-indigo-950 font-mono">
                ₹{(kpis.revenuesThrough2PercentFees ?? kpis.revenuesThrough5PercentFees)?.toLocaleString()}
              </div>
              <p className="text-[10px] text-indigo-800 font-medium">Platform ops & infrastructure (2%)</p>
            </div>

            {/* KPI 6: Total PF & Insurance (Worker Welfare Fund) */}
            <div className="p-4 rounded-2xl bg-teal-50 border-2 border-teal-400 space-y-1">
              <span className="text-[10px] font-bold text-teal-900 uppercase tracking-wider">
                6. Total PF & Insurance Fund
              </span>
              <div className="text-xl font-extrabold text-teal-950 font-mono">
                ₹{kpis.totalWorkersWelfareFundRaised?.toLocaleString()}
              </div>
              <p className="text-[10px] text-teal-800 font-medium">5% statutory PF & insurance</p>
            </div>

            {/* KPI 7: Total Loan Amount Disbursed */}
            <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 space-y-1">
              <span className="text-[10px] font-bold text-amber-900 uppercase tracking-wider">
                7. Total Loan Disbursed
              </span>
              <div className="text-xl font-extrabold text-amber-950 font-mono">
                ₹{kpis.totalLoanAmountDisbursed?.toLocaleString()}
              </div>
              <p className="text-[10px] text-amber-800 font-medium">Artisan toolkit micro-loans</p>
            </div>

            {/* KPI 8: Next Loan Amount Due */}
            <div className="p-4 rounded-2xl bg-orange-50 border border-orange-200 space-y-1">
              <span className="text-[10px] font-bold text-orange-900 uppercase tracking-wider">
                8. Next Loan Due Amount
              </span>
              <div className="text-xl font-extrabold text-orange-950 font-mono">
                ₹{kpis.nextLoanAmountDue?.toLocaleString()}
              </div>
              <p className="text-[10px] text-orange-800 font-medium">Due by: {kpis.nextLoanDueDate}</p>
            </div>

            {/* KPI 9: Project Funds Received */}
            <div className="p-4 rounded-2xl bg-cyan-50 border border-cyan-200 space-y-1">
              <span className="text-[10px] font-bold text-cyan-900 uppercase tracking-wider">
                9. Project Funds Received
              </span>
              <div className="text-xl font-extrabold text-cyan-950 font-mono">
                ₹{kpis.projectFundsReceived?.toLocaleString()}
              </div>
              <p className="text-[10px] text-cyan-800 font-medium">Institutional tender advances</p>
            </div>

            {/* KPI 10: Due Remaining for Projects */}
            <div className="p-4 rounded-2xl bg-slate-100 border border-slate-300 space-y-1">
              <span className="text-[10px] font-bold text-slate-800 uppercase tracking-wider">
                10. Due Remaining on Projects
              </span>
              <div className="text-xl font-extrabold text-slate-950 font-mono">
                ₹{kpis.dueRemainingForProjects?.toLocaleString()}
              </div>
              <p className="text-[10px] text-slate-700 font-medium">Milestone payments pending</p>
            </div>
          </div>

          {/* Treasury Ledger History */}
          <div className="bg-white rounded-2xl border border-gray-200 p-6 shadow-xs space-y-4">
            <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider">
              Statutory Treasury Transactions Ledger
            </h3>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs border-collapse">
                <thead className="bg-gray-50 text-gray-700 border-b border-gray-200 text-[10px] uppercase font-semibold">
                  <tr>
                    <th className="p-3">Txn Code</th>
                    <th className="p-3">Category</th>
                    <th className="p-3">Description</th>
                    <th className="p-3">Amount</th>
                    <th className="p-3">Balance After</th>
                    <th className="p-3">Timestamp</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700">
                  {treasurerData.ledger?.map((t) => (
                    <tr key={t.id} className="hover:bg-gray-50/50">
                      <td className="p-3 font-mono font-bold text-blue-900">{t.transaction_code}</td>
                      <td className="p-3">
                        <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                          t.amount >= 0 ? 'bg-emerald-100 text-emerald-900' : 'bg-rose-100 text-rose-900'
                        }`}>
                          {t.transaction_type}
                        </span>
                      </td>
                      <td className="p-3 text-gray-600">{t.description}</td>
                      <td className={`p-3 font-mono font-bold ${t.amount >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                        {t.amount >= 0 ? '+' : ''}₹{Math.abs(t.amount).toLocaleString()}
                      </td>
                      <td className="p-3 font-mono font-extrabold text-gray-900">
                        ₹{t.balance_after.toLocaleString()}
                      </td>
                      <td className="p-3 text-gray-400 text-[10px]">
                        {new Date(t.created_at).toLocaleDateString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          MODAL 1: ONBOARD WORKER UNDER FEDERATION (PAGE 2)
         ───────────────────────────────────────────────────────────── */}
      {showWorkerModal && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4 border border-gray-200">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3">
              <div>
                <h3 className="text-base font-bold text-gray-900 flex items-center gap-1.5">
                  <Plus size={18} className="text-blue-900" /> Onboard Artisan under Federation
                </h3>
                <p className="text-xs text-gray-500">
                  Federation takes formal responsibility for verified quality and workmanship.
                </p>
              </div>
              <button
                onClick={() => setShowWorkerModal(false)}
                className="text-gray-400 hover:text-gray-600 font-bold text-base"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleRegisterWorker} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Artisan Full Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Bijay Kumar Swain"
                  value={workerFormData.name}
                  onChange={(e) => setWorkerFormData({ ...workerFormData, name: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg"
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Email ID *</label>
                  <input
                    type="email"
                    required
                    placeholder="artisan@demo.local"
                    value={workerFormData.email}
                    onChange={(e) => setWorkerFormData({ ...workerFormData, email: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Phone *</label>
                  <input
                    type="tel"
                    required
                    placeholder="9876543000"
                    value={workerFormData.phone}
                    onChange={(e) => setWorkerFormData({ ...workerFormData, phone: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Primary Trade *</label>
                  <select
                    value={workerFormData.primaryTrade}
                    onChange={(e) => setWorkerFormData({ ...workerFormData, primaryTrade: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg bg-white"
                  >
                    <option value="Electrical">Electrical</option>
                    <option value="Plumbing">Plumbing</option>
                    <option value="Carpentry">Carpentry</option>
                    <option value="Appliance Repair">Appliance Repair</option>
                    <option value="Painting">Painting</option>
                  </select>
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Experience (Years) *</label>
                  <input
                    type="number"
                    min="0"
                    max="40"
                    value={workerFormData.experienceYears}
                    onChange={(e) => setWorkerFormData({ ...workerFormData, experienceYears: parseFloat(e.target.value) || 0 })}
                    className="w-full p-2 border border-gray-300 rounded-lg"
                  />
                </div>
              </div>

              <div className="p-3 rounded-lg bg-purple-50 border border-purple-200 flex items-center gap-2">
                <input
                  type="checkbox"
                  id="ncct-check"
                  checked={workerFormData.isNcctCertified}
                  onChange={(e) => setWorkerFormData({ ...workerFormData, isNcctCertified: e.target.checked })}
                  className="h-4 w-4 text-purple-600 rounded"
                />
                <label htmlFor="ncct-check" className="cursor-pointer font-semibold text-purple-950">
                  Artisan holds NCCT / ITI Certification (Accelerates Gold / Master tier)
                </label>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowWorkerModal(false)}
                  className="btn btn-secondary btn-sm"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={registeringWorker}
                  className="btn btn-primary btn-sm font-bold"
                >
                  {registeringWorker ? 'Registering...' : 'Register Worker under Federation'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          MODAL 2: APPLY FOR NCCT TRAINING (PAGE 3)
         ───────────────────────────────────────────────────────────── */}
      {showNcctModal && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4 border border-gray-200">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3">
              <div>
                <h3 className="text-base font-bold text-gray-900 flex items-center gap-1.5">
                  <GraduationCap size={18} className="text-purple-700" /> Apply for Subsidized NCCT Training
                </h3>
                <p className="text-xs text-gray-500">
                  Federation applies for NCCT training with 80% National Federation subsidy.
                </p>
              </div>
              <button
                onClick={() => setShowNcctModal(false)}
                className="text-gray-400 hover:text-gray-600 font-bold text-base"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleApplyNcct} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Artisan Candidate Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Suresh Behera"
                  value={ncctFormData.workerName}
                  onChange={(e) => setNcctFormData({ ...ncctFormData, workerName: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Trade *</label>
                <select
                  value={ncctFormData.trade}
                  onChange={(e) => setNcctFormData({ ...ncctFormData, trade: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg bg-white"
                >
                  <option value="Electrical">Electrical</option>
                  <option value="Plumbing">Plumbing</option>
                  <option value="Appliance Repair">Appliance Repair</option>
                  <option value="Carpentry">Carpentry</option>
                  <option value="Cooperative Governance">Cooperative Accountancy & Governance</option>
                </select>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">NCCT Certification Course Module *</label>
                <input
                  type="text"
                  required
                  value={ncctFormData.courseName}
                  onChange={(e) => setNcctFormData({ ...ncctFormData, courseName: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg"
                />
              </div>

              {/* Subsidized Fee Breakdown */}
              <div className="p-3.5 rounded-xl bg-purple-50 border border-purple-200 space-y-1 text-purple-950">
                <span className="font-bold block text-[11px] uppercase tracking-wider">Subsidized Training Fee Structure</span>
                <div className="flex justify-between text-[11px]">
                  <span>Total Course Cost:</span>
                  <span className="font-mono">₹2,500</span>
                </div>
                <div className="flex justify-between text-[11px] text-emerald-700 font-bold">
                  <span>National Federation Subsidy (80%):</span>
                  <span className="font-mono">- ₹2,000</span>
                </div>
                <div className="flex justify-between text-xs font-extrabold border-t border-purple-200 pt-1 text-purple-900">
                  <span>Net Payable by Federation:</span>
                  <span className="font-mono">₹500 / worker</span>
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowNcctModal(false)}
                  className="btn btn-secondary btn-sm"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={applyingNcct}
                  className="btn btn-primary btn-sm font-bold bg-purple-800 hover:bg-purple-700 border-purple-800"
                >
                  {applyingNcct ? 'Submitting Application...' : 'Nominate & Enroll in NCCT'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
