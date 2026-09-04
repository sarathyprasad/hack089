import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import {
  Building2, Users, FileText, CheckCircle2, AlertCircle, ArrowRight,
  ArrowLeft, ShieldCheck, Landmark, UploadCloud, Search, Clock, Award,
  Sparkles, ChevronRight, FileCheck, Check, Plus, Trash2, HelpCircle
} from 'lucide-react';

export default function SocietyRegistration() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('NEW_FORMATION'); // 'NEW_FORMATION' or 'TRACK_STATUS'

  // Wizard Steps (1 to 7 interactive form, 8 & 9 timeline tracking)
  const [currentStep, setCurrentStep] = useState(1);

  // Form State
  const [formData, setFormData] = useState({
    name: '',
    registered_email: '',
    registered_phone: '',
    district: 'Khordha',
    city: 'Bhubaneswar',
    address: '',
    pincode: '751001',
    objectives: 'To organize and empower skilled blue-collar artisans with fair statutory wages, social security welfare, and collective institutional contract bidding.',
    initial_capital_balance: 25000,
    bank_account_no: '',
    cooperative_bank_name: 'District Central Cooperative Bank',
    bank_ifsc: '',
  });

  // Founding Members (Minimum 10 Required - Page 1)
  const [foundingMembers, setFoundingMembers] = useState([
    { full_name: 'Bibhuti Bhusan Sahoo', occupation: 'Master Electrician', address: 'Plot 12, Main Road', phone: '9861001101', aadhaar_number: '****-****-1101', role_in_society: 'PRESIDENT' },
    { full_name: 'Subhashree Mohanty', occupation: 'Accountancy Specialist', address: 'Lane 4, High Street', phone: '9861001102', aadhaar_number: '****-****-1102', role_in_society: 'SECRETARY' },
    { full_name: 'Prafulla Kumar Jena', occupation: 'Senior Master Plumber', address: 'Station Road', phone: '9861001103', aadhaar_number: '****-****-1103', role_in_society: 'TREASURER' },
    { full_name: 'Girish Chandra Dash', occupation: 'Senior Carpenter', address: 'Market Square', phone: '9861001104', aadhaar_number: '****-****-1104', role_in_society: 'MEMBER' },
    { full_name: 'Jayanti Pradhan', occupation: 'Appliance Technician', address: 'Colony Street 2', phone: '9861001105', aadhaar_number: '****-****-1105', role_in_society: 'MEMBER' },
    { full_name: 'Manoranjan Behera', occupation: 'Industrial Mason', address: 'Industrial Area', phone: '9861001106', aadhaar_number: '****-****-1106', role_in_society: 'MEMBER' },
    { full_name: 'Sasmita Sahoo', occupation: 'Decorative Painter', address: 'Temple Road', phone: '9861001107', aadhaar_number: '****-****-1107', role_in_society: 'MEMBER' },
    { full_name: 'Tuna Barik', occupation: 'Sanitary Specialist', address: 'Bus Stand Lane', phone: '9861001108', aadhaar_number: '****-****-1108', role_in_society: 'MEMBER' },
    { full_name: 'Bikash Mohapatra', occupation: 'Solar Technician', address: 'Green Energy Park', phone: '9861001109', aadhaar_number: '****-****-1109', role_in_society: 'MEMBER' },
    { full_name: 'Hemant Kumar Swain', occupation: 'HVAC AC Mechanic', address: 'Coastal Colony', phone: '9861001110', aadhaar_number: '****-****-1110', role_in_society: 'MEMBER' },
  ]);

  const [newMember, setNewMember] = useState({
    full_name: '',
    occupation: '',
    address: '',
    phone: '',
    aadhaar_number: '',
    role_in_society: 'MEMBER',
  });

  // Track Status State
  const [searchTrackingId, setSearchTrackingId] = useState('');
  const [trackedSociety, setTrackedSociety] = useState(null);
  const [trackingLoading, setTrackingLoading] = useState(false);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [submittedData, setSubmittedData] = useState(null);

  // Add member to founding roster
  const handleAddMember = (e) => {
    e.preventDefault();
    if (!newMember.full_name || !newMember.occupation) {
      setError('Member Name and Occupation are required.');
      return;
    }
    setFoundingMembers([...foundingMembers, { ...newMember }]);
    setNewMember({
      full_name: '',
      occupation: '',
      address: '',
      phone: '',
      aadhaar_number: '',
      role_in_society: 'MEMBER',
    });
    setError('');
  };

  const handleRemoveMember = (index) => {
    setFoundingMembers(foundingMembers.filter((_, i) => i !== index));
  };

  // Submit 9-Step Formation Application
  const handleSubmitApplication = async () => {
    setError('');
    if (foundingMembers.length < 10) {
      setError(`Cooperative Societies Act requires at least 10 founding members. Currently added: ${foundingMembers.length}`);
      return;
    }

    if (formData.initial_capital_balance < 10000) {
      setError('Minimum initial capital of ₹10,000 in a cooperative bank is required by statute.');
      return;
    }

    setLoading(true);
    try {
      const payload = {
        ...formData,
        founding_members: foundingMembers,
      };

      const res = await api.registerSociety(payload);
      if (res.success) {
        setSubmittedData(res.data);
        setCurrentStep(7); // Jump to Success Receipt & Timeline Step
      }
    } catch (err) {
      setError(err.message || 'Failed to submit society application.');
    } finally {
      setLoading(false);
    }
  };

  // Lookup existing tracking ID
  const handleTrackSubmit = async (e) => {
    e.preventDefault();
    if (!searchTrackingId.trim()) return;
    setTrackingLoading(true);
    setError('');
    try {
      const res = await api.getSocietyTracking(searchTrackingId.trim());
      if (res.success) {
        setTrackedSociety(res.data);
      }
    } catch (err) {
      setError(err.message || 'Tracking ID not found.');
      setTrackedSociety(null);
    } finally {
      setTrackingLoading(false);
    }
  };

  return (
    <div className="container py-8 max-w-5xl mx-auto space-y-6">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-blue-950 via-indigo-900 to-blue-900 rounded-2xl p-6 md:p-8 text-white shadow-md relative overflow-hidden">
        <div className="relative z-10 space-y-2">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-200 text-xs font-bold uppercase tracking-wider">
            <Building2 size={14} className="text-amber-400" />
            National Federation of Labour Cooperatives • Statutory Formation Portal
          </div>
          <h1 className="text-2xl md:text-3xl font-extrabold text-white">
            Cooperative Society Registration & Formation Workflow
          </h1>
          <p className="text-xs md:text-sm text-blue-200 max-w-3xl">
            Legal formation process under the Cooperative Societies Act for new artisan collectives, district federations, and labour associations to become certified and eligible on <strong>Shram Setu</strong>.
          </p>
        </div>

        {/* Top Tab Bar */}
        <div className="mt-6 flex flex-wrap gap-2 relative z-10 border-t border-blue-800/60 pt-4">
          <button
            onClick={() => { setActiveTab('NEW_FORMATION'); setError(''); }}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 ${
              activeTab === 'NEW_FORMATION'
                ? 'bg-amber-400 text-blue-950 shadow-sm'
                : 'bg-blue-900/50 text-blue-200 hover:bg-blue-800'
            }`}
          >
            <Plus size={14} /> New Society Registration (9-Step Legal Formation)
          </button>
          <button
            onClick={() => { setActiveTab('TRACK_STATUS'); setError(''); }}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 ${
              activeTab === 'TRACK_STATUS'
                ? 'bg-amber-400 text-blue-950 shadow-sm'
                : 'bg-blue-900/50 text-blue-200 hover:bg-blue-800'
            }`}
          >
            <Search size={14} /> Track Application / Statutory Timeline
          </button>
          <Link
            to="/society/timeline"
            className="px-4 py-2 rounded-xl text-xs font-bold bg-blue-900/50 text-blue-200 hover:bg-blue-800 transition flex items-center gap-2"
          >
            <Clock size={14} /> Recognized Societies Progression
          </Link>
          <Link
            to="/login?role=admin"
            className="px-4 py-2 rounded-xl text-xs font-bold bg-emerald-600 text-white hover:bg-emerald-500 transition flex items-center gap-2 ml-auto shadow-xs"
          >
            <Award size={14} /> Federation Login & Portal (Credentials Required) <ArrowRight size={14} />
          </Link>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-xs flex items-start gap-2">
          <AlertCircle size={16} className="shrink-0 mt-0.5 text-red-600" />
          <div>{error}</div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 1: NEW SOCIETY 9-STEP FORMATION WIZARD (PAGE 1)
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'NEW_FORMATION' && (
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6 md:p-8 space-y-6">
          {/* Step Indicator */}
          <div className="border-b border-gray-100 pb-4">
            <div className="flex items-center justify-between overflow-x-auto gap-2 pb-2">
              {[
                { s: 1, title: 'Application Form' },
                { s: 2, title: '10 Founding Members' },
                { s: 3, title: 'Bylaws & Resolution' },
                { s: 4, title: 'Bank Certificate (₹10k)' },
                { s: 5, title: 'Affidavit' },
                { s: 6, title: 'Review & Submit' },
                { s: 7, title: 'Unique ID & Timeline' },
              ].map((step) => (
                <div
                  key={step.s}
                  className={`flex items-center gap-1.5 shrink-0 px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                    currentStep === step.s
                      ? 'bg-blue-900 text-white shadow-xs'
                      : currentStep > step.s
                      ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
                      : 'bg-gray-100 text-gray-400'
                  }`}
                >
                  <span className="w-4 h-4 rounded-full flex items-center justify-center text-[10px] bg-white/20">
                    {currentStep > step.s ? '✓' : step.s}
                  </span>
                  <span>{step.title}</span>
                </div>
              ))}
            </div>
          </div>

          {/* STEP 1: Application Form */}
          {currentStep === 1 && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                  <FileText size={18} className="text-blue-900" />
                  Step 1: Society Details & Operational Objectives
                </h2>
                <span className="text-xs text-gray-500 font-medium">Application Form</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="sm:col-span-2">
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Proposed Society Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Kalinga Shramik Seva Sahakari Samiti"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Registered Email *
                  </label>
                  <input
                    type="email"
                    required
                    placeholder="e.g. kalinga.coop@gov.in"
                    value={formData.registered_email}
                    onChange={(e) => setFormData({ ...formData, registered_email: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Registered Phone *
                  </label>
                  <input
                    type="tel"
                    required
                    placeholder="e.g. 0674-2548800"
                    value={formData.registered_phone}
                    onChange={(e) => setFormData({ ...formData, registered_phone: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Operational District *
                  </label>
                  <select
                    value={formData.district}
                    onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs bg-white focus:ring-2 focus:ring-blue-900"
                  >
                    <option value="Khordha">Khordha (Bhubaneswar)</option>
                    <option value="Cuttack">Cuttack</option>
                    <option value="Puri">Puri</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    City / Locality *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Master Canteen, Saheed Nagar"
                    value={formData.city}
                    onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Head Office Physical Address *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Plot No 88, Near District Cooperative Bank"
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Primary Objectives & Trades Served *
                  </label>
                  <textarea
                    rows={2}
                    value={formData.objectives}
                    onChange={(e) => setFormData({ ...formData, objectives: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900 resize-none"
                  />
                </div>
              </div>

              <div className="flex justify-end pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => {
                    if (!formData.name || !formData.registered_email) {
                      setError('Please enter society name and email.');
                      return;
                    }
                    setError('');
                    setCurrentStep(2);
                  }}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 text-xs font-bold"
                >
                  Continue to 10 Founding Members <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 2: Founding Members (Minimum 10 Validation - Page 1) */}
          {currentStep === 2 && (
            <div className="space-y-5">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                <div>
                  <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                    <Users size={18} className="text-blue-900" />
                    Step 2: Founding Member Roster (Statutory Minimum: 10 Members)
                  </h2>
                  <p className="text-xs text-gray-500 mt-0.5">
                    Cooperative law mandates that at least 10 founding artisans with valid proof of identity and residence sign the formation charter.
                  </p>
                </div>

                <div className={`px-3 py-1.5 rounded-full text-xs font-extrabold flex items-center gap-1.5 ${
                  foundingMembers.length >= 10
                    ? 'bg-emerald-100 text-emerald-900 border border-emerald-300'
                    : 'bg-amber-100 text-amber-900 border border-amber-300'
                }`}>
                  {foundingMembers.length >= 10 ? <CheckCircle2 size={14} className="text-emerald-700" /> : <AlertCircle size={14} className="text-amber-700" />}
                  Founding Members: {foundingMembers.length} / 10 {foundingMembers.length >= 10 ? '(Statute Satisfied)' : '(Add More)'}
                </div>
              </div>

              {/* Members Table */}
              <div className="border border-gray-200 rounded-xl overflow-hidden shadow-xs">
                <div className="max-h-64 overflow-y-auto">
                  <table className="w-full text-left text-xs border-collapse">
                    <thead className="bg-gray-50 text-gray-700 sticky top-0 border-b border-gray-200 uppercase tracking-wider font-semibold text-[10px]">
                      <tr>
                        <th className="p-2.5">#</th>
                        <th className="p-2.5">Full Name</th>
                        <th className="p-2.5">Occupation / Trade</th>
                        <th className="p-2.5">Aadhaar ID</th>
                        <th className="p-2.5">Role</th>
                        <th className="p-2.5 text-center">Action</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100 text-gray-700">
                      {foundingMembers.map((m, idx) => (
                        <tr key={idx} className="hover:bg-blue-50/40">
                          <td className="p-2.5 font-bold text-gray-400">{idx + 1}</td>
                          <td className="p-2.5 font-semibold text-gray-900">{m.full_name}</td>
                          <td className="p-2.5">{m.occupation}</td>
                          <td className="p-2.5 font-mono text-[11px] text-gray-500">{m.aadhaar_number}</td>
                          <td className="p-2.5">
                            <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                              m.role_in_society === 'PRESIDENT' ? 'bg-blue-100 text-blue-900' :
                              m.role_in_society === 'SECRETARY' ? 'bg-purple-100 text-purple-900' :
                              m.role_in_society === 'TREASURER' ? 'bg-emerald-100 text-emerald-900' : 'bg-gray-100 text-gray-600'
                            }`}>
                              {m.role_in_society}
                            </span>
                          </td>
                          <td className="p-2.5 text-center">
                            <button
                              type="button"
                              onClick={() => handleRemoveMember(idx)}
                              className="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50"
                            >
                              <Trash2 size={13} />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Add New Member Mini Form */}
              <div className="p-4 rounded-xl bg-gray-50 border border-gray-200 space-y-3">
                <span className="text-xs font-bold text-gray-800 flex items-center gap-1.5">
                  <Plus size={14} className="text-blue-900" /> Add Additional Founding Member
                </span>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                  <input
                    type="text"
                    placeholder="Full Name"
                    value={newMember.full_name}
                    onChange={(e) => setNewMember({ ...newMember, full_name: e.target.value })}
                    className="p-2 border border-gray-300 rounded text-xs bg-white"
                  />
                  <input
                    type="text"
                    placeholder="Occupation / Trade"
                    value={newMember.occupation}
                    onChange={(e) => setNewMember({ ...newMember, occupation: e.target.value })}
                    className="p-2 border border-gray-300 rounded text-xs bg-white"
                  />
                  <input
                    type="text"
                    placeholder="Aadhaar ID (****-****-1234)"
                    value={newMember.aadhaar_number}
                    onChange={(e) => setNewMember({ ...newMember, aadhaar_number: e.target.value })}
                    className="p-2 border border-gray-300 rounded text-xs bg-white"
                  />
                </div>
                <div className="flex justify-end">
                  <button
                    type="button"
                    onClick={handleAddMember}
                    className="btn btn-secondary btn-sm text-xs font-bold"
                  >
                    + Add to Member Roster
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setCurrentStep(1)}
                  className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
                >
                  <ArrowLeft size={14} /> Back
                </button>

                <button
                  type="button"
                  disabled={foundingMembers.length < 10}
                  onClick={() => {
                    setError('');
                    setCurrentStep(3);
                  }}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 text-xs font-bold disabled:opacity-50"
                >
                  Continue to Bylaws & Resolution <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 3: Bylaws & Resolution (Page 1) */}
          {currentStep === 3 && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <FileCheck size={18} className="text-blue-900" />
                Step 3: Society Model Bylaws & Formation Resolution
              </h2>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="p-4 rounded-xl border border-blue-200 bg-blue-50/40 space-y-2">
                  <span className="text-xs font-bold text-blue-950 flex items-center gap-1.5">
                    📜 Model Cooperative Bylaws (Act Aligned)
                  </span>
                  <p className="text-[11px] text-gray-600 leading-relaxed">
                    Governs democratic membership voting, annual officer elections, 93-2-5 transparent accounting, and formal dispute settlement mechanisms under State / Multi-State Cooperative Societies Act.
                  </p>
                  <div className="p-2 rounded bg-white border border-blue-200 text-[11px] text-emerald-800 font-semibold flex items-center gap-1.5">
                    <CheckCircle2 size={14} className="text-emerald-600" /> Standard Model Bylaws Pack Attached (PDF)
                  </div>
                </div>

                <div className="p-4 rounded-xl border border-purple-200 bg-purple-50/40 space-y-2">
                  <span className="text-xs font-bold text-purple-950 flex items-center gap-1.5">
                    ✍️ Minutes of General Meeting & Resolution
                  </span>
                  <p className="text-[11px] text-gray-600 leading-relaxed">
                    Formal minutes of the inaugural general meeting where all 10 founding members resolved to create the society, signed by President and Secretary.
                  </p>
                  <div className="p-2 rounded bg-white border border-purple-200 text-[11px] text-purple-800 font-semibold flex items-center gap-1.5">
                    <CheckCircle2 size={14} className="text-purple-600" /> Resolution No. 01/2026 Verified & Signed
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setCurrentStep(2)}
                  className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
                >
                  <ArrowLeft size={14} /> Back
                </button>

                <button
                  type="button"
                  onClick={() => setCurrentStep(4)}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 text-xs font-bold"
                >
                  Continue to Bank Certificate <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 4: Bank Certificate (Min ₹10,000 - Page 1) */}
          {currentStep === 4 && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <Landmark size={18} className="text-blue-900" />
                Step 4: Bank Certificate (Proof of Minimum ₹10,000 Initial Capital)
              </h2>

              <div className="p-4 rounded-xl bg-amber-50/60 border border-amber-200 text-xs text-amber-900 flex items-start gap-2">
                <AlertCircle size={16} className="shrink-0 mt-0.5 text-amber-700" />
                <div>
                  <strong>Statutory Bank Certificate Requirement:</strong> Proof of initial member capital contribution deposited in a recognized Cooperative Bank with a minimum opening balance of <strong>₹10,000</strong>.
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Initial Capital Balance Deposited (₹) *
                  </label>
                  <input
                    type="number"
                    min="10000"
                    required
                    value={formData.initial_capital_balance}
                    onChange={(e) => setFormData({ ...formData, initial_capital_balance: parseFloat(e.target.value) || 0 })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs font-bold text-blue-950 font-mono focus:ring-2 focus:ring-blue-900"
                  />
                  <span className="text-[10px] text-gray-500 mt-0.5 block">Minimum ₹10,000 mandatory</span>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Cooperative Bank Name *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.cooperative_bank_name}
                    onChange={(e) => setFormData({ ...formData, cooperative_bank_name: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Society Bank Account Number *
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. COOP-9988112233"
                    value={formData.bank_account_no}
                    onChange={(e) => setFormData({ ...formData, bank_account_no: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs font-mono focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                    Bank IFSC Code *
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. OSCB0001002"
                    value={formData.bank_ifsc}
                    onChange={(e) => setFormData({ ...formData, bank_ifsc: e.target.value })}
                    className="w-full p-2.5 border border-gray-300 rounded-lg text-xs font-mono uppercase focus:ring-2 focus:ring-blue-900"
                  />
                </div>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setCurrentStep(3)}
                  className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
                >
                  <ArrowLeft size={14} /> Back
                </button>

                <button
                  type="button"
                  onClick={() => {
                    if (formData.initial_capital_balance < 10000) {
                      setError('Minimum initial capital balance of ₹10,000 is required.');
                      return;
                    }
                    setError('');
                    setCurrentStep(5);
                  }}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 text-xs font-bold"
                >
                  Continue to Affidavit <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 5: Affidavit (Page 1) */}
          {currentStep === 5 && (
            <div className="space-y-4">
              <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <ShieldCheck size={18} className="text-blue-900" />
                Step 5: Non-Profit & Cooperative Principles Affidavit
              </h2>

              <div className="p-5 rounded-xl border border-gray-300 bg-gray-50/70 space-y-3">
                <h4 className="text-xs font-bold text-gray-900 uppercase tracking-wider">
                  Official Statutory Declaration (Affidavit Form IV)
                </h4>
                <p className="text-xs text-gray-600 leading-relaxed">
                  We, the executive founding members of <strong>{formData.name || 'the proposed society'}</strong>, solemnly declare that the society will operate lawfully under the Cooperative Societies Act, uphold the 7 international cooperative principles, distribute 93% statutory labour earnings directly to member artisans, allocate 2% for platform fee, 5% to the PF & insurance (worker welfare) fund, and refrain from private profiteering beyond cooperative bylaws.
                </p>
                <div className="pt-2 flex items-center gap-2 text-xs font-semibold text-blue-950">
                  <input type="checkbox" defaultChecked id="affidavit-check" className="h-4 w-4 rounded text-blue-900" />
                  <label htmlFor="affidavit-check">I confirm this affidavit is verified and signed before a Notary Public.</label>
                </div>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setCurrentStep(4)}
                  className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
                >
                  <ArrowLeft size={14} /> Back
                </button>

                <button
                  type="button"
                  onClick={() => setCurrentStep(6)}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 text-xs font-bold"
                >
                  Review Application Dossier <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 6: Final Review & Submit */}
          {currentStep === 6 && (
            <div className="space-y-5">
              <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <Sparkles size={18} className="text-blue-900" />
                Step 6: Review Complete 9-Step Formation Dossier
              </h2>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                <div className="p-4 rounded-xl bg-gray-50 border border-gray-200 space-y-2">
                  <span className="font-bold text-gray-800 uppercase tracking-wider text-[11px] block">Society Summary</span>
                  <div className="space-y-1 text-gray-700">
                    <p><strong>Name:</strong> {formData.name}</p>
                    <p><strong>District:</strong> {formData.district} ({formData.city})</p>
                    <p><strong>Email:</strong> {formData.registered_email}</p>
                    <p><strong>Phone:</strong> {formData.registered_phone}</p>
                    <p><strong>Initial Capital:</strong> ₹{formData.initial_capital_balance.toLocaleString()} ({formData.cooperative_bank_name})</p>
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-gray-50 border border-gray-200 space-y-2">
                  <span className="font-bold text-gray-800 uppercase tracking-wider text-[11px] block">Statutory Dossier Documents</span>
                  <ul className="space-y-1.5 text-emerald-800 font-semibold">
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> Signed Application (Form-1)</li>
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> 10 Verified Founding Members Roster</li>
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> Act-Aligned Cooperative Bylaws</li>
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> Meeting Resolution of Formation</li>
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> Bank Certificate (₹{formData.initial_capital_balance.toLocaleString()})</li>
                    <li className="flex items-center gap-1.5"><Check size={14} className="text-emerald-600" /> Non-Profit Principles Affidavit</li>
                  </ul>
                </div>
              </div>

              <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setCurrentStep(5)}
                  className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
                >
                  <ArrowLeft size={14} /> Back
                </button>

                <button
                  type="button"
                  disabled={loading}
                  onClick={handleSubmitApplication}
                  className="btn btn-primary btn-sm flex items-center gap-2 text-xs font-bold px-6 py-2.5 shadow-sm"
                >
                  {loading ? 'Submitting Dossier...' : 'Submit to District Registrar & Generate Unique ID'}
                  <ArrowRight size={14} />
                </button>
              </div>
            </div>
          )}

          {/* STEP 7: Success Receipt & Unique ID Generated (Page 1) */}
          {currentStep === 7 && submittedData && (
            <div className="space-y-6 text-center max-w-2xl mx-auto py-4">
              <div className="w-16 h-16 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center mx-auto shadow-xs">
                <CheckCircle2 size={36} />
              </div>

              <div className="space-y-1">
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-800 bg-emerald-50 px-3 py-1 rounded-full border border-emerald-200">
                  Dossier Submitted • Stage 7
                </span>
                <h2 className="text-xl font-bold text-gray-900">
                  Unique Tracking ID & Statutory Receipt Generated!
                </h2>
                <p className="text-xs text-gray-600">
                  Your society formation dossier has been recorded. You can track compliance audits and registrar certification using this ID.
                </p>
              </div>

              {/* Unique ID Badge */}
              <div className="p-4 rounded-xl bg-blue-50 border-2 border-blue-900 text-blue-950 inline-block font-mono text-lg font-extrabold tracking-wider shadow-xs">
                {submittedData.tracking_id}
              </div>

              {/* Next Steps Timeline (Page 1) */}
              <div className="p-4 rounded-xl bg-gray-50 border border-gray-200 text-left space-y-3 text-xs">
                <h4 className="font-bold text-gray-900 uppercase tracking-wider text-[11px]">
                  Upcoming Statutory Steps & Timeline
                </h4>
                <div className="space-y-2">
                  <div className="flex items-start gap-2">
                    <span className="w-5 h-5 rounded-full bg-blue-900 text-white flex items-center justify-center font-bold text-[10px] shrink-0 mt-0.5">8</span>
                    <div>
                      <strong className="text-gray-900">Register with Registrar of Cooperatives:</strong>
                      <p className="text-gray-600 text-[11px]">Submit hardcopy dossier to District Registrar office for statutory legal verification.</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <span className="w-5 h-5 rounded-full bg-amber-500 text-white flex items-center justify-center font-bold text-[10px] shrink-0 mt-0.5">9</span>
                    <div>
                      <strong className="text-gray-900">Approval & Certification:</strong>
                      <p className="text-gray-600 text-[11px]">Registrar issues official Certificate of Registration. Society becomes a legal entity and is <strong>Eligible to Be in Shram Setu</strong>.</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => {
                    setSearchTrackingId(submittedData.tracking_id);
                    setActiveTab('TRACK_STATUS');
                  }}
                  className="btn btn-primary btn-sm text-xs font-bold"
                >
                  Track Live Timeline
                </button>
                <Link to="/federation/portal" className="btn btn-secondary btn-sm text-xs font-bold">
                  Go to Federation Portal
                </Link>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          TAB 2: TRACK APPLICATION / TIMELINE LOOKUP
         ───────────────────────────────────────────────────────────── */}
      {activeTab === 'TRACK_STATUS' && (
        <div className="bg-white rounded-2xl border border-gray-200 shadow-xs p-6 md:p-8 space-y-6">
          <div>
            <h2 className="text-base font-bold text-gray-900 flex items-center gap-2">
              <Search size={18} className="text-blue-900" />
              Track Society Registration Dossier & Legal Recognition
            </h2>
            <p className="text-xs text-gray-500 mt-0.5">
              Enter your Unique Tracking ID (e.g. <code>SS-SOC-2024-001</code>, <code>SS-SOC-2026-9812</code>) to check statutory status with the District Registrar.
            </p>
          </div>

          <form onSubmit={handleTrackSubmit} className="flex gap-2 max-w-lg">
            <input
              type="text"
              required
              placeholder="e.g. SS-SOC-2026-9812"
              value={searchTrackingId}
              onChange={(e) => setSearchTrackingId(e.target.value)}
              className="grow p-2.5 border border-gray-300 rounded-lg text-xs font-mono uppercase focus:ring-2 focus:ring-blue-900"
            />
            <button
              type="submit"
              disabled={trackingLoading}
              className="btn btn-primary btn-sm text-xs font-bold px-5"
            >
              {trackingLoading ? 'Searching...' : 'Track Dossier'}
            </button>
          </form>

          {/* Tracked Society Details */}
          {trackedSociety && (
            <div className="space-y-6 pt-4 border-t border-gray-100">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-4 rounded-xl bg-blue-50 border border-blue-200">
                <div>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-blue-900">
                    Tracking ID: {trackedSociety.society.tracking_id}
                  </span>
                  <h3 className="text-base font-bold text-blue-950">{trackedSociety.society.name}</h3>
                  <p className="text-xs text-blue-800">
                    District: {trackedSociety.society.district} • Status: <strong className="uppercase">{trackedSociety.society.status}</strong>
                  </p>
                </div>

                <span className={`px-3 py-1 rounded-full text-xs font-extrabold shrink-0 ${
                  trackedSociety.society.status === 'ACTIVE'
                    ? 'bg-emerald-600 text-white'
                    : 'bg-amber-500 text-white'
                }`}>
                  Stage {trackedSociety.society.timeline_stage || 7} of 9
                </span>
              </div>

              {/* 9-Stage Visual Timeline */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold text-gray-800 uppercase tracking-wider">
                  9-Step Legal Formation Timeline
                </h4>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 text-xs">
                  {[
                    { n: 1, label: 'Application Form', done: true },
                    { n: 2, label: '10 Founding Members', done: true },
                    { n: 3, label: 'Bylaws Act-Aligned', done: true },
                    { n: 4, label: 'Formation Resolution', done: true },
                    { n: 5, label: 'Bank Cert (₹10k Min)', done: true },
                    { n: 6, label: 'Affidavit Verified', done: true },
                    { n: 7, label: 'Unique ID Generated', done: true },
                    { n: 8, label: 'District Registrar Review', done: trackedSociety.society.timeline_stage >= 8 },
                    { n: 9, label: 'Eligible in Shram Setu', done: trackedSociety.society.timeline_stage >= 9 },
                  ].map((s) => (
                    <div
                      key={s.n}
                      className={`p-3 rounded-lg border flex items-center gap-2 ${
                        s.done
                          ? 'bg-emerald-50 border-emerald-200 text-emerald-900 font-semibold'
                          : 'bg-gray-50 border-gray-200 text-gray-400'
                      }`}
                    >
                      <span className={`w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold ${
                        s.done ? 'bg-emerald-600 text-white' : 'bg-gray-200 text-gray-600'
                      }`}>
                        {s.done ? '✓' : s.n}
                      </span>
                      <span className="text-[11px]">{s.label}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Member Roster Preview */}
              {trackedSociety.founding_members && (
                <div className="space-y-2">
                  <h4 className="text-xs font-bold text-gray-800 uppercase tracking-wider">
                    Founding Members on Record ({trackedSociety.founding_members.length})
                  </h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                    {trackedSociety.founding_members.slice(0, 6).map((m, i) => (
                      <div key={i} className="p-2.5 rounded-lg border border-gray-200 bg-gray-50/50 flex items-center justify-between">
                        <div>
                          <strong className="text-gray-900">{m.full_name}</strong>
                          <p className="text-[11px] text-gray-500">{m.occupation}</p>
                        </div>
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-100 text-blue-900">
                          {m.role_in_society}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
