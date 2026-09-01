import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../services/api';
import { useAuth } from '../context/AuthContext';
import {
  Briefcase, CheckCircle2, AlertTriangle, Star, ShieldCheck,
  Calendar, Clock, MapPin, Phone, Building2, Award, Zap,
  TrendingUp, IndianRupee, HeartPulse, RefreshCw, Check, X, Play,
  Volume2, ShieldAlert, Camera, Plus, Wrench, Shield
} from 'lucide-react';

export default function WorkerDashboard() {
  const { user } = useAuth();

  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('ACTIVE'); // INCOMING, ACTIVE, COMPLETED, REVIEWS
  const [actionBusyId, setActionBusyId] = useState(null);
  const [availabilityUpdating, setAvailabilityUpdating] = useState(false);

  // OTP Handshake & Work Execution Modals
  const [otpTargetBooking, setOtpTargetBooking] = useState(null);
  const [otpType, setOtpType] = useState('ARRIVAL'); // ARRIVAL or COMPLETION
  const [enteredOtp, setEnteredOtp] = useState('');
  const [otpLoading, setOtpLoading] = useState(false);

  // Photo Proof State
  const [photoTargetBooking, setPhotoTargetBooking] = useState(null);
  const [photoType, setPhotoType] = useState('PRE'); // PRE or POST
  const [photoUrl, setPhotoUrl] = useState('');

  // Add Parts State
  const [partsTargetBooking, setPartsTargetBooking] = useState(null);
  const [partsCatalog, setPartsCatalog] = useState([]);
  const [selectedParts, setSelectedParts] = useState([]);
  const [partsLoading, setPartsLoading] = useState(false);

  // SOS State
  const [sosActive, setSosActive] = useState(false);
  const [sosLoading, setSosLoading] = useState(false);

  const fetchDashboard = () => {
    setLoading(true);
    api.getWorkerDashboard()
      .then((data) => setDashboardData(data))
      .catch((err) => console.error('Failed to load worker dashboard:', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchDashboard();
  }, []);

  const handleAvailabilityChange = async (newStatus) => {
    setAvailabilityUpdating(true);
    try {
      await api.updateWorkerAvailability(newStatus);
      fetchDashboard();
    } catch (err) {
      console.error('Failed to update availability:', err);
      alert('Could not update availability status.');
    } finally {
      setAvailabilityUpdating(false);
    }
  };

  // Voice Job Alert using Web Speech API (Phase 3)
  const handleVoiceAlert = (job) => {
    if (!('speechSynthesis' in window)) {
      alert('Web speech not supported in this browser.');
      return;
    }
    const utterance = new SpeechSynthesisUtterance(
      `New work order. Service: ${job.service_name}. Location: ${job.location_address}, ${job.location_city}. Scheduled for ${job.scheduled_date} at ${job.scheduled_time}. Tariff: ${job.total_amount} rupees.`
    );
    utterance.rate = 0.95;
    window.speechSynthesis.speak(utterance);
  };

  // Trigger One-Tap SOS Emergency Beacon (Phase 4)
  const handleTriggerSos = async () => {
    if (!window.confirm('🚨 TRIGGER EMERGENCY SOS BEACON?\n\nThis will send an immediate high-priority safety alert with your live GPS location to the District Cooperative Federation Supervisor and peer response squad.')) {
      return;
    }
    setSosLoading(true);
    try {
      const res = await api.triggerSos({
        latitude: 20.2961,
        longitude: 85.8245,
        details: 'Emergency SOS button triggered from worker dashboard.',
      });
      setSosActive(true);
      alert(res.message);
    } catch (err) {
      alert(err.message || 'Failed to activate SOS beacon.');
    } finally {
      setSosLoading(false);
    }
  };

  // Verify Arrival or Completion OTP (Phase 4)
  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    if (!enteredOtp || !otpTargetBooking) return;

    setOtpLoading(true);
    try {
      if (otpType === 'ARRIVAL') {
        const res = await api.verifyArrivalOtp(otpTargetBooking.id, enteredOtp);
        alert(res.message || 'Arrival verified! Status is now IN_PROGRESS.');
      } else {
        const res = await api.verifyCompletionOtp(otpTargetBooking.id, enteredOtp);
        alert(res.message || 'Job completed! Merit points awarded and 7-Day Guarantee armed.');
      }
      setOtpTargetBooking(null);
      setEnteredOtp('');
      fetchDashboard();
    } catch (err) {
      alert(err.message || 'Incorrect OTP code.');
    } finally {
      setOtpLoading(false);
    }
  };

  // Upload Photo Proof (Phase 4)
  const handleSavePhotoProof = async (e) => {
    e.preventDefault();
    if (!photoTargetBooking) return;
    const url = photoUrl.trim() || (photoType === 'PRE'
      ? 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400'
      : 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400');

    try {
      await api.uploadPhotoProof(photoTargetBooking.id, photoType, url);
      alert(`${photoType === 'PRE' ? 'Pre-job' : 'Post-job'} photo recorded.`);
      setPhotoTargetBooking(null);
      setPhotoUrl('');
      fetchDashboard();
    } catch (err) {
      alert(err.message || 'Failed to save photo.');
    }
  };

  // Open Parts Catalog Modal
  const handleOpenPartsModal = async (booking) => {
    setPartsTargetBooking(booking);
    setPartsLoading(true);
    try {
      const res = await api.getPartsCatalog();
      setPartsCatalog(res.parts || []);
    } catch (err) {
      console.error('Failed to load parts:', err);
    } finally {
      setPartsLoading(false);
    }
  };

  // Submit Selected Parts
  const handleAddPartsSubmit = async () => {
    if (selectedParts.length === 0 || !partsTargetBooking) return;
    try {
      await api.addPartsToBooking(partsTargetBooking.id, selectedParts);
      alert('Standard parts successfully added to work order invoice.');
      setPartsTargetBooking(null);
      setSelectedParts([]);
      fetchDashboard();
    } catch (err) {
      alert(err.message || 'Failed to add parts.');
    }
  };

  const handleAction = async (bookingId, action) => {
    setActionBusyId(bookingId);
    try {
      await api.handleWorkerJobAction(bookingId, action);
      fetchDashboard();
    } catch (err) {
      console.error(`Action ${action} failed:`, err);
      alert(err.message || 'Action failed.');
    } finally {
      setActionBusyId(null);
    }
  };

  if (loading) {
    return (
      <div className="container py-20 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
        <p className="text-xs text-gray-500">Loading worker profile and security dispatch queue...</p>
      </div>
    );
  }

  const { worker, skills, certifications, stats, incomingJobs, activeJobs, completedJobs, reviews } = dashboardData || {};

  return (
    <div className="container py-8 max-w-6xl mx-auto space-y-6">
      {/* ── PENDING / REJECTED VERIFICATION STATUS BANNER ── */}
      {worker?.verification_status === 'PENDING' && (
        <div className="p-6 bg-gradient-to-r from-amber-50 to-orange-50 rounded-2xl border-2 border-amber-300 shadow-sm space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center font-bold text-xl shrink-0 shadow-sm">
                ⏳
              </div>
              <div>
                <span className="text-[10px] font-extrabold uppercase tracking-widest px-2.5 py-0.5 rounded bg-amber-200 text-amber-950 border border-amber-300">
                  Accreditation Under Administrative Review
                </span>
                <h2 className="text-base sm:text-lg font-bold text-slate-900 mt-1">
                  Application Reference: <span className="font-mono text-blue-950">{worker?.application_no || 'APP-OD-2026-PENDING'}</span>
                </h2>
                <p className="text-xs text-slate-600">
                  Assigned to: <strong>{worker?.cooperative_name || 'District Labour Cooperative Federation'}</strong>
                </p>
              </div>
            </div>
            <div className="text-left sm:text-right">
              <span className="text-[11px] font-semibold text-amber-800 block">
                Primary Trade: <strong>{worker?.primary_trade || 'Skilled Artisan'}</strong>
              </span>
              <span className="text-[10px] text-slate-500 block mt-0.5">
                Dispatch console will activate upon District Officer approval.
              </span>
            </div>
          </div>

          {/* 4-Step Verification Timeline */}
          <div className="pt-3 border-t border-amber-200/80 grid grid-cols-1 sm:grid-cols-4 gap-3 text-xs">
            <div className="p-3 bg-white/80 rounded-xl border border-emerald-300 text-emerald-950">
              <div className="font-bold flex items-center gap-1.5 text-[11px]">
                <CheckCircle2 size={14} className="text-emerald-700" />
                <span>1. Digital Dossier</span>
              </div>
              <p className="text-[10px] text-emerald-800 mt-1">Submitted & Logged in State Register</p>
            </div>

            <div className="p-3 bg-amber-100/80 rounded-xl border border-amber-400 text-amber-950">
              <div className="font-bold flex items-center gap-1.5 text-[11px]">
                <Clock size={14} className="text-amber-700" />
                <span>2. ITI & KYC Audit</span>
              </div>
              <p className="text-[10px] text-amber-800 mt-1">Under verification by Federation SPIO</p>
            </div>

            <div className="p-3 bg-white/60 rounded-xl border border-slate-200 text-slate-500">
              <div className="font-bold flex items-center gap-1.5 text-[11px]">
                <span className="w-3.5 h-3.5 rounded-full border border-slate-400 inline-block text-center text-[9px]">3</span>
                <span>3. Officer Approval</span>
              </div>
              <p className="text-[10px] text-slate-400 mt-1">Accreditation Badge & Code Issuance</p>
            </div>

            <div className="p-3 bg-white/60 rounded-xl border border-slate-200 text-slate-500">
              <div className="font-bold flex items-center gap-1.5 text-[11px]">
                <span className="w-3.5 h-3.5 rounded-full border border-slate-400 inline-block text-center text-[9px]">4</span>
                <span>4. Live Dispatch</span>
              </div>
              <p className="text-[10px] text-slate-400 mt-1">Available for customer work orders</p>
            </div>
          </div>
        </div>
      )}

      {worker?.verification_status === 'REJECTED' && (
        <div className="p-5 bg-red-50 rounded-2xl border-2 border-red-300 shadow-sm space-y-2 text-xs text-red-900">
          <div className="flex items-center gap-2">
            <AlertTriangle size={20} className="text-red-600 shrink-0" />
            <strong className="text-sm font-bold text-red-950">
              Application Disapproved by District Cooperative Officer
            </strong>
          </div>
          <p className="text-xs text-red-800">
            <strong>Reason for Rejection:</strong> {worker?.rejection_reason || 'Trade certificate or KYC records could not be verified.'}
          </p>
          <p className="text-[11px] text-red-700">
            Please contact your District Labour Cooperative Federation SPIO at <strong>1800-345-6789</strong> or visit Lok Seva Bhawan for re-verification.
          </p>
        </div>
      )}

      {/* Header & Worker ID Profile Banner */}
      <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-gray-100">
          <div className="flex items-start gap-4">
            <div className="w-16 h-16 rounded-2xl bg-blue-950 text-white font-bold text-2xl flex flex-col items-center justify-center shrink-0 shadow-md">
              <span>{user?.name?.charAt(0) || 'W'}</span>
              <span className="text-[8px] font-mono text-amber-400">{worker?.tier || 'BRONZE'}</span>
            </div>
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="text-xl font-bold text-gray-900">{user?.name}</h1>
                <span className="font-mono text-xs font-bold px-2 py-0.5 rounded bg-gray-100 text-gray-800 border border-gray-200">
                  {worker?.worker_code}
                </span>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                  worker?.tier === 'MASTER'
                    ? 'bg-amber-100 text-amber-900 border-amber-300'
                    : 'bg-blue-100 text-blue-900 border-blue-300'
                }`}>
                  {worker?.tier || 'BRONZE'} ARTISAN ({worker?.merit_points || 100} Merit Pts)
                </span>
                <span className={`inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded ${
                  worker?.verification_status === 'VERIFIED'
                    ? 'bg-emerald-100 text-emerald-800 border border-emerald-200'
                    : worker?.verification_status === 'REJECTED'
                    ? 'bg-red-100 text-red-800 border border-red-200'
                    : 'bg-amber-100 text-amber-800 border border-amber-200'
                }`}>
                  {worker?.verification_status === 'VERIFIED' ? <CheckCircle2 size={12} /> : <Clock size={12} />}
                  {worker?.verification_status}
                </span>
              </div>

              <div className="text-xs text-gray-600 mt-1 flex items-center gap-3 flex-wrap">
                <span className="flex items-center gap-1 font-medium">
                  <Building2 size={13} className="text-blue-900" /> {worker?.cooperative_name}
                </span>
                <span>•</span>
                <span className="flex items-center gap-1">
                  <MapPin size={13} className="text-blue-900" /> {worker?.service_area || worker?.city}, {worker?.district}
                </span>
                <span>•</span>
                <span>{worker?.primary_trade || 'Artisan'} • {worker?.experience_years} Yrs Exp</span>
              </div>
            </div>
          </div>

          {/* Action buttons: SOS Beacon & Availability Switch */}
          <div className="flex items-center gap-3 flex-wrap">
            {/* 1-Tap SOS Beacon */}
            <button
              onClick={handleTriggerSos}
              disabled={sosLoading || worker?.verification_status !== 'VERIFIED'}
              className={`btn btn-sm font-bold flex items-center gap-1.5 shadow-md ${
                sosActive
                  ? 'bg-red-600 text-white animate-bounce'
                  : 'bg-red-50 text-red-700 border border-red-300 hover:bg-red-600 hover:text-white disabled:opacity-50'
              }`}
            >
              <ShieldAlert size={14} />
              {sosActive ? '🚨 SOS ACTIVE' : '1-Tap SOS Beacon'}
            </button>

            {/* Availability Toggle (Disabled if not VERIFIED) */}
            <div className="flex items-center p-1 bg-gray-100 rounded-xl border border-gray-200">
              {['AVAILABLE', 'BUSY', 'OFFLINE'].map((status) => {
                const isActive = worker?.availability === status;
                const isDisabled = worker?.verification_status !== 'VERIFIED' || availabilityUpdating;
                return (
                  <button
                    key={status}
                    type="button"
                    disabled={isDisabled}
                    onClick={() => handleAvailabilityChange(status)}
                    title={worker?.verification_status !== 'VERIFIED' ? 'Duty console locked until cooperative admin verification' : ''}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                      isActive
                        ? status === 'AVAILABLE'
                          ? 'bg-emerald-600 text-white shadow-xs'
                          : status === 'BUSY'
                          ? 'bg-amber-600 text-white shadow-xs'
                          : 'bg-gray-700 text-white shadow-xs'
                        : 'text-gray-600 hover:text-gray-900'
                    } ${isDisabled ? 'cursor-not-allowed opacity-60' : ''}`}
                  >
                    {status}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* 4-KPI Summary Banner */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-6">
          <div className="p-3.5 bg-blue-50/60 rounded-xl border border-blue-200">
            <span className="text-[10px] font-bold uppercase text-blue-900">Total Lifetime Payouts</span>
            <div className="text-lg font-bold font-mono text-blue-950 mt-0.5">
              ₹{worker?.total_earnings?.toLocaleString('en-IN') || '0'}
            </div>
            <span className="text-[10px] text-gray-500">90% Direct Wallet Payout</span>
          </div>

          <div className="p-3.5 bg-emerald-50/60 rounded-xl border border-emerald-200">
            <span className="text-[10px] font-bold uppercase text-emerald-900">Completed Orders</span>
            <div className="text-lg font-bold font-mono text-emerald-950 mt-0.5">
              {worker?.total_jobs_completed || 0} Gigs
            </div>
            <span className="text-[10px] text-emerald-700 font-semibold">100% On-Time Rate</span>
          </div>

          <div className="p-3.5 bg-amber-50/60 rounded-xl border border-amber-200">
            <span className="text-[10px] font-bold uppercase text-amber-900">Artisan Rating</span>
            <div className="text-lg font-bold text-amber-950 mt-0.5 flex items-center gap-1">
              <Star size={16} className="text-amber-500 fill-amber-500" />
              {worker?.rating > 0 ? worker.rating.toFixed(1) : '4.8'}
            </div>
            <span className="text-[10px] text-gray-500">({worker?.total_reviews || 0} reviews)</span>
          </div>

          <div className="p-3.5 bg-indigo-50/60 rounded-xl border border-indigo-200">
            <span className="text-[10px] font-bold uppercase text-indigo-900">Merit Points</span>
            <div className="text-lg font-bold font-mono text-indigo-950 mt-0.5">
              {worker?.merit_points || 100} pts
            </div>
            <span className="text-[10px] text-indigo-700 font-semibold">Tier: {worker?.tier || 'MASTER'}</span>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex border-b border-gray-200 gap-6 text-xs font-bold">
        {[
          { key: 'ACTIVE', label: `Active Tasks (${activeJobs?.length || 0})` },
          { key: 'INCOMING', label: `Dispatch Inbox (${incomingJobs?.length || 0})` },
          { key: 'COMPLETED', label: `Completed Orders (${completedJobs?.length || 0})` },
          { key: 'REVIEWS', label: `Feedback & Reviews (${reviews?.length || 0})` },
        ].map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`pb-3 border-b-2 transition ${
              activeTab === tab.key
                ? 'border-blue-950 text-blue-950'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* ─────────────────────────────────────────────────────────────
          ACTIVE JOBS WITH FULL 5-STEP HANDSHAKE CONTROLS
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'ACTIVE' && (
        <div className="space-y-4">
          {activeJobs?.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-xl border border-gray-200 text-gray-500 text-xs">
              No jobs currently in progress. Check the Dispatch Inbox for new bookings.
            </div>
          ) : (
            activeJobs.map((job) => (
              <div key={job.id} className="bg-white p-6 rounded-2xl border border-gray-200 shadow-xs space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-3 border-b border-gray-100">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs font-bold text-blue-900">{job.booking_code}</span>
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded uppercase ${
                        job.status === 'IN_PROGRESS'
                          ? 'bg-blue-100 text-blue-900'
                          : 'bg-yellow-100 text-yellow-900'
                      }`}>
                        {job.status}
                      </span>
                    </div>
                    <h3 className="font-bold text-base text-gray-900 mt-1">{job.service_name}</h3>
                  </div>
                  <div className="text-right">
                    <span className="text-xs text-gray-500">Net Labour Payout:</span>
                    <div className="text-lg font-bold font-mono text-emerald-700">₹{job.amount}</div>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs text-gray-600 bg-gray-50 p-3.5 rounded-xl">
                  <div>
                    <span className="text-gray-500 block">Customer:</span>
                    <strong>{job.customer_name}</strong> (Ph: {job.customer_phone || '9876543210'})
                  </div>
                  <div>
                    <span className="text-gray-500 block">Address:</span>
                    <strong>{job.location_address}, {job.location_city}</strong>
                  </div>
                </div>

                {/* 5-Step Execution Handshake Action Buttons for Worker */}
                <div className="p-4 bg-blue-50/50 rounded-xl border border-blue-200 space-y-3">
                  <div className="text-xs font-bold text-blue-950 flex items-center justify-between">
                    <span>Phase 4 Job Execution Handshakes</span>
                    <span className="text-[10px] text-blue-800 font-normal">Protocol compliant</span>
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {/* 1. Enter Arrival OTP */}
                    {job.status === 'ACCEPTED' && (
                      <button
                        onClick={() => {
                          setOtpTargetBooking(job);
                          setOtpType('ARRIVAL');
                        }}
                        className="btn btn-primary btn-sm text-xs font-bold flex items-center gap-1"
                      >
                        <ShieldCheck size={13} /> 1. Enter Customer Arrival OTP
                      </button>
                    )}

                    {/* 2. Upload Pre-Job Photo Proof */}
                    {job.status === 'IN_PROGRESS' && (
                      <button
                        onClick={() => {
                          setPhotoTargetBooking(job);
                          setPhotoType('PRE');
                        }}
                        className="btn btn-secondary btn-sm text-xs flex items-center gap-1"
                      >
                        <Camera size={13} /> 2. {job.pre_job_photo_url ? '✓ Pre-Job Photo Saved' : 'Add Pre-Job Photo'}
                      </button>
                    )}

                    {/* 3. Add Locked Parts */}
                    {job.status === 'IN_PROGRESS' && (
                      <button
                        onClick={() => handleOpenPartsModal(job)}
                        className="btn btn-secondary btn-sm text-xs flex items-center gap-1"
                      >
                        <Wrench size={13} /> 3. Add Parts (Price Matrix)
                      </button>
                    )}

                    {/* 4. Upload Post-Job Photo Proof */}
                    {job.status === 'IN_PROGRESS' && (
                      <button
                        onClick={() => {
                          setPhotoTargetBooking(job);
                          setPhotoType('POST');
                        }}
                        className="btn btn-secondary btn-sm text-xs flex items-center gap-1"
                      >
                        <Camera size={13} /> 4. {job.post_job_photo_url ? '✓ Post-Job Photo Saved' : 'Add Post-Job Photo'}
                      </button>
                    )}

                    {/* 5. Enter Completion OTP */}
                    {job.status === 'IN_PROGRESS' && (
                      <button
                        onClick={() => {
                          setOtpTargetBooking(job);
                          setOtpType('COMPLETION');
                        }}
                        className="btn btn-saffron btn-sm text-xs font-bold flex items-center gap-1"
                      >
                        <CheckCircle2 size={13} /> 5. Enter Completion OTP & Finish
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          INCOMING JOBS WITH VOICE ALERT & INSTANT ACCEPT
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'INCOMING' && (
        <div className="space-y-4">
          {incomingJobs?.length === 0 ? (
            <div className="text-center py-12 bg-white rounded-xl border border-gray-200 text-gray-500 text-xs">
              No new incoming requests in dispatch inbox.
            </div>
          ) : (
            incomingJobs.map((job) => (
              <div key={job.id} className="bg-white p-5 rounded-2xl border border-gray-200 shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold text-blue-900">{job.booking_code}</span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-100 text-blue-900">
                      NEW DISPATCH
                    </span>
                  </div>
                  <h3 className="font-bold text-sm text-gray-900 mt-1">{job.service_name}</h3>
                  <div className="text-xs text-gray-500 mt-0.5">
                    📍 {job.location_address}, {job.location_city} • 📅 {job.scheduled_date} at {job.scheduled_time}
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleVoiceAlert(job)}
                    className="p-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition"
                    title="Play voice audio alert in your regional language"
                  >
                    <Volume2 size={16} />
                  </button>
                  <button
                    onClick={() => handleAction(job.id, 'ACCEPT')}
                    disabled={actionBusyId === job.id}
                    className="btn btn-primary btn-sm text-xs font-bold flex items-center gap-1"
                  >
                    <Check size={13} /> Accept
                  </button>
                  <button
                    onClick={() => handleAction(job.id, 'DECLINE')}
                    disabled={actionBusyId === job.id}
                    className="btn btn-secondary btn-sm text-xs text-gray-600"
                  >
                    Decline (Zero Penalty)
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          COMPLETED JOBS
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'COMPLETED' && (
        <div className="space-y-3">
          {completedJobs?.map((job) => (
            <div key={job.id} className="bg-white p-4 rounded-xl border border-gray-200 flex items-center justify-between text-xs">
              <div>
                <span className="font-mono font-bold text-blue-900">{job.booking_code}</span>
                <div className="font-bold text-gray-900 mt-0.5">{job.service_name}</div>
                <div className="text-gray-500">{job.scheduled_date} • Customer: {job.customer_name}</div>
              </div>
              <div className="text-right">
                <span className="font-bold font-mono text-emerald-700 text-sm">₹{job.amount}</span>
                <div className="text-[10px] text-emerald-700 font-semibold">✓ Paid & Closed</div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          REVIEWS
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'REVIEWS' && (
        <div className="space-y-3">
          {reviews?.map((r) => (
            <div key={r.id} className="bg-white p-4 rounded-xl border border-gray-200 space-y-1 text-xs">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-1 text-amber-500 font-bold">
                  {'★'.repeat(r.rating)}{'☆'.repeat(5 - r.rating)} ({r.rating}/5)
                </div>
                <span className="text-gray-400 text-[10px]">{r.created_at?.split('T')[0]}</span>
              </div>
              <p className="text-gray-800 italic">"{r.comment}"</p>
              <div className="text-[11px] text-gray-500 pt-1">Citizen: {r.customer_name}</div>
            </div>
          ))}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          OTP HANDSHAKE MODAL
         ───────────────────────────────────────────────────────────── */}
      {otpTargetBooking && (
        <div
          onClick={(e) => { if (e.target === e.currentTarget) setOtpTargetBooking(null); }}
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs"
        >
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-bold text-sm text-blue-950">
                {otpType === 'ARRIVAL' ? 'Enter Customer Arrival OTP' : 'Enter Completion OTP'}
              </h3>
              <button
                type="button"
                onClick={() => setOtpTargetBooking(null)}
                className="p-1 rounded-lg text-gray-400 hover:text-gray-700 hover:bg-gray-100"
              >
                <X size={18} />
              </button>
            </div>

            <p className="text-xs text-gray-600">
              {otpType === 'ARRIVAL'
                ? 'Ask the customer for the 4-digit Arrival OTP shown on their screen to unlock work.'
                : 'Ask the customer for the 4-digit Completion OTP once the task is finished.'}
            </p>

            <form onSubmit={handleVerifyOtp} className="space-y-4">
              <input
                type="text"
                maxLength={4}
                required
                autoFocus
                placeholder="4-digit OTP"
                value={enteredOtp}
                onChange={(e) => setEnteredOtp(e.target.value)}
                className="w-full text-center tracking-widest font-mono text-2xl py-2.5 rounded-xl border border-gray-300 focus:ring-2 focus:ring-blue-900"
              />

              <div className="flex justify-end gap-2 pt-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setOtpTargetBooking(null)}
                  className="btn btn-secondary btn-sm"
                >
                  Cancel / Close
                </button>
                <button
                  type="submit"
                  disabled={otpLoading || enteredOtp.length < 4}
                  className="btn btn-primary btn-sm font-bold"
                >
                  {otpLoading ? 'Verifying...' : 'Verify OTP Handshake'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHOTO PROOF MODAL
         ───────────────────────────────────────────────────────────── */}
      {photoTargetBooking && (
        <div
          onClick={(e) => { if (e.target === e.currentTarget) setPhotoTargetBooking(null); }}
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs"
        >
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b pb-3">
              <h3 className="font-bold text-sm text-blue-950">
                {photoType === 'PRE' ? 'Capture Pre-Job Fault Photo' : 'Capture Post-Job Completed Photo'}
              </h3>
              <button onClick={() => setPhotoTargetBooking(null)}><X size={16} /></button>
            </div>

            <p className="text-xs text-gray-600">
              Photos are automatically timestamped and geotagged to the work order.
            </p>

            <form onSubmit={handleSavePhotoProof} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-700 mb-1">Photo URL or Camera Capture</label>
                <input
                  type="text"
                  placeholder="https://... (or leave default for demo snapshot)"
                  value={photoUrl}
                  onChange={(e) => setPhotoUrl(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl border border-gray-300 text-xs"
                />
              </div>

              <div className="flex justify-end gap-2">
                <button type="button" onClick={() => setPhotoTargetBooking(null)} className="btn btn-secondary btn-sm">
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary btn-sm flex items-center gap-1">
                  <Camera size={13} /> Save Photo Proof
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          LOCKED PARTS PRICE MATRIX MODAL
         ───────────────────────────────────────────────────────────── */}
      {partsTargetBooking && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4 max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between border-b pb-3">
              <div className="flex items-center gap-2">
                <Wrench size={16} className="text-blue-900" />
                <h3 className="font-bold text-sm text-blue-950">Add Spare Parts from Locked Price Matrix</h3>
              </div>
              <button onClick={() => setPartsTargetBooking(null)}><X size={16} /></button>
            </div>

            <p className="text-xs text-gray-500">
              Select standardized government-approved replacement parts. Prices are locked and billed directly to the customer invoice without markup.
            </p>

            <div className="overflow-y-auto flex-1 space-y-2 pr-1">
              {partsCatalog.map((part) => {
                const isAdded = selectedParts.some((p) => p.partName === part.part_name);
                return (
                  <div key={part.id} className="p-3 rounded-xl border border-gray-200 flex items-center justify-between text-xs">
                    <div>
                      <div className="font-bold text-gray-900">{part.part_name}</div>
                      <span className="text-[10px] text-gray-500">{part.trade_category} • {part.warranty_months}m warranty</span>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="font-bold font-mono text-blue-950">₹{part.standard_price}</span>
                      {isAdded ? (
                        <button
                          onClick={() => setSelectedParts(selectedParts.filter((p) => p.partName !== part.part_name))}
                          className="px-2 py-1 rounded bg-red-100 text-red-700 text-[10px] font-bold"
                        >
                          Remove
                        </button>
                      ) : (
                        <button
                          onClick={() => setSelectedParts([...selectedParts, { partId: part.id, partName: part.part_name, price: part.standard_price, quantity: 1 }])}
                          className="px-2 py-1 rounded bg-blue-900 text-white text-[10px] font-bold"
                        >
                          + Add
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>

            <div className="pt-3 border-t flex items-center justify-between text-xs">
              <span>Selected: <strong>{selectedParts.length} parts</strong></span>
              <div className="flex gap-2">
                <button onClick={() => setPartsTargetBooking(null)} className="btn btn-secondary btn-sm">Cancel</button>
                <button onClick={handleAddPartsSubmit} disabled={selectedParts.length === 0} className="btn btn-primary btn-sm">
                  Add to Invoice
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
