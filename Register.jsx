import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  UserPlus, UserCheck, Briefcase, Mail, Lock, Phone, MapPin, Building2,
  AlertCircle, ShieldCheck, Award, Wrench, FileText, CheckCircle2,
  ChevronRight, ChevronLeft, Landmark, CreditCard, Sparkles, Check, Clock
} from 'lucide-react';

const TRADES = [
  { id: 'Electrical', name: 'Electrical Engineering & Wiring', icon: '⚡' },
  { id: 'Plumbing', name: 'Plumbing & Sanitary Works', icon: '🚰' },
  { id: 'Appliance Repair', name: 'AC & Home Appliance Servicing', icon: '🔧' },
  { id: 'Painting', name: 'Painting & Waterproofing Works', icon: '🎨' },
  { id: 'Carpentry', name: 'Carpentry & Teak Furniture', icon: '🔨' },
  { id: 'Cleaning', name: 'Deep Cleaning & Sanitization', icon: '🧹' },
  { id: 'Gardening', name: 'Horticulture & Landscaping', icon: '🌱' },
  { id: 'Caregiving', name: 'Elderly & Patient Caregiving', icon: '❤️' },
  { id: 'Driving', name: 'Certified Driver Transit', icon: '🚗' },
  { id: 'Domestic Services', name: 'Domestic Housekeeping', icon: '🏠' },
  { id: 'Technician Services', name: 'IT & Hardware Technician', icon: '💻' },
  { id: 'Emergency Services', name: '24/7 Emergency Priority Trades', icon: '🚨' },
];

const SKILL_SUGGESTIONS = {
  'Electrical': ['Single-Phase Wiring', '3-Phase Industrial', 'Inverter & Solar UPS', 'MCB Short Circuit Faults', 'Concealed Conduit', 'Appliance Earthing'],
  'Plumbing': ['CPVC Concealed Piping', 'Overhead Tank Cleaning', 'Bathroom Sanitary Fixtures', 'Water Pump Motor Repair', 'Drainage Unclogging'],
  'Appliance Repair': ['Inverter AC Gas Charging', 'Refrigerator Compressor PCB', 'Washing Machine Motor', 'Microwave Magnetron', 'Water Purifier RO Membrane'],
  'Painting': ['Waterproof Acrylic Primer', 'Exterior Weathercoat', 'Interior Wall Putty', 'Texture & Stencil Design', 'Enamel Wood Polish'],
  'Carpentry': ['Modular Kitchen Hinges', 'Door Lock Fitting', 'Teakwood Framing', 'Sofa & Bed Repair', 'Plywood Partition'],
  'Cleaning': ['Kitchen Degreasing', 'Bathroom Floor Scrubbing', 'Sofa Shampooing', 'Balcony Sanitization', 'Post-Construction Cleanup'],
  'Gardening': ['Lawn Mowing & Leveling', 'Organic Pest Spray', 'Bonsai & Floral Pruning', 'Balcony Planter Setup'],
  'Caregiving': ['Geriatric Mobility Care', 'Post-Op Vital Monitoring', 'Physiotherapy Support', 'Emergency First Aid'],
  'Driving': ['Manual Gearbox', 'Automatic Transmission', 'Inter-District Highway Transit', 'Night Driving Certified'],
  'Domestic Services': ['Nutritious Meal Cooking', 'Dusting & Floor Mopping', 'Apparel Ironing', 'Dishwashing'],
  'Technician Services': ['CCTV Camera IP Setup', 'Fiber WiFi Router Splicing', 'Desktop OS & Motherboard Diagnostics', 'UPS Battery Setup'],
  'Emergency Services': ['Live Phase Short Circuit Control', 'Main Water Line Burst Clamping', 'Emergency Night Callout'],
};

export default function Register() {
  const { register, error } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  // Selected Role: 'CUSTOMER' | 'WORKER'
  const initialRole = searchParams.get('role') === 'worker' ? 'WORKER' : 'CUSTOMER';
  const [role, setRole] = useState(initialRole);

  // Sync role with URL search param if it changes
  useEffect(() => {
    const urlRole = searchParams.get('role');
    if (urlRole === 'worker') {
      setRole('WORKER');
    } else if (urlRole === 'customer') {
      setRole('CUSTOMER');
    }
  }, [searchParams]);

  // Worker Wizard Step (1: Basic, 2: Skills & Work, 3: Certifications, 4: KYC & Bank, 5: Success)
  const [wizardStep, setWizardStep] = useState(1);

  // Form State
  const [formData, setFormData] = useState({
    // Step 1: Basic Details
    name: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    district: 'Khordha',
    city: 'Bhubaneswar',
    address: '',
    pincode: '751024',

    // Step 2: Trade Skills & Work Profile
    primaryTrade: 'Electrical',
    subSkills: ['Single-Phase Wiring', 'MCB Short Circuit Faults'],
    experienceYears: 3,
    toolsOwned: 'Digital Multimeter, Heavy Hammer Drill, Safety Gloves, Wire Stripper, Soldering Kit',
    dailyAvailability: 'FULL_TIME',
    bio: 'Certified artisan with extensive hands-on experience in residential and commercial installations.',

    // Step 3: Certifications
    certificationType: 'ITI_NCVT',
    certificationName: 'National Trade Certificate (NTC) — Electrician',
    issuingOrganization: 'Government ITI Bhubaneswar / NCVT',
    certificateNumber: 'ITI-OD-2022-8821',
    issueDate: '2022-07-15',
    hasUploadedCert: true,

    // Step 4: KYC & Banking Details
    aadhaarNumber: '',
    panNumber: '',
    rationCard: '',
    bankName: 'State Bank of India',
    bankAccount: '',
    confirmBankAccount: '',
    bankIfsc: 'SBIN0001234',
    emergencyContactName: '',
    emergencyContactPhone: '',
    emergencyContactRelation: 'Spouse',
    acceptedUndertaking: false,
  });

  const [loading, setLoading] = useState(false);
  const [localError, setLocalError] = useState('');
  const [submittedApplicationNo, setSubmittedApplicationNo] = useState('');

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const toggleSubSkill = (skill) => {
    const current = [...formData.subSkills];
    const index = current.indexOf(skill);
    if (index > -1) {
      current.splice(index, 1);
    } else {
      current.push(skill);
    }
    setFormData((prev) => ({ ...prev, subSkills: current }));
  };

  // Step 1 Validation
  const validateStep1 = () => {
    if (!formData.name.trim()) return 'Please enter your full legal name.';
    if (!formData.email.trim() || !formData.email.includes('@')) return 'Please enter a valid email address.';
    if (!formData.phone.trim() || formData.phone.length < 10) return 'Please enter a valid 10-digit mobile number.';
    if (formData.password.length < 6) return 'Password must be at least 6 characters.';
    if (formData.password !== formData.confirmPassword) return 'Passwords do not match.';
    if (!formData.address.trim()) return 'Please provide your residential address for police & federation records.';
    return null;
  };

  // Step 2 Validation
  const validateStep2 = () => {
    if (!formData.primaryTrade) return 'Please select your primary trade.';
    if (formData.subSkills.length === 0) return 'Please select at least one sub-skill specialization.';
    if (!formData.toolsOwned.trim()) return 'Please list the primary tools and safety equipment you own.';
    return null;
  };

  // Step 3 Validation
  const validateStep3 = () => {
    if (!formData.certificateNumber.trim()) return 'Please provide your Trade Certificate or Registration Number.';
    if (!formData.issuingOrganization.trim()) return 'Please provide the name of the issuing ITI / Institute.';
    return null;
  };

  // Step 4 Validation
  const validateStep4 = () => {
    if (!formData.aadhaarNumber.trim() || formData.aadhaarNumber.replace(/\D/g, '').length < 12) {
      return 'Please enter a valid 12-digit Aadhaar Card number for statutory verification.';
    }
    if (!formData.panNumber.trim() || formData.panNumber.length < 10) {
      return 'Please enter a valid 10-character PAN Card number.';
    }
    if (!formData.bankAccount.trim()) {
      return 'Please enter your bank account number for direct 90% instant earnings payout.';
    }
    if (formData.bankAccount !== formData.confirmBankAccount) {
      return 'Bank account numbers do not match.';
    }
    if (!formData.bankIfsc.trim()) {
      return 'Please enter the Bank Branch IFSC Code.';
    }
    if (!formData.emergencyContactName.trim() || !formData.emergencyContactPhone.trim()) {
      return 'Please provide an emergency contact name and phone number.';
    }
    if (!formData.acceptedUndertaking) {
      return 'You must accept the statutory legal undertaking under the Odisha Cooperative Societies Act.';
    }
    return null;
  };

  const handleNextStep = (e) => {
    if (e) e.preventDefault();
    setLocalError('');
    let err = null;
    if (wizardStep === 1) err = validateStep1();
    else if (wizardStep === 2) err = validateStep2();
    else if (wizardStep === 3) err = validateStep3();

    if (err) {
      setLocalError(err);
      return;
    }
    setWizardStep((prev) => prev + 1);
  };

  const handlePrevStep = () => {
    setLocalError('');
    setWizardStep((prev) => Math.max(1, prev - 1));
  };

  // Handle Submission (Customer 1-step or Worker Final step)
  const handleSubmit = async (e) => {
    if (e) e.preventDefault();
    setLocalError('');

    if (role === 'CUSTOMER') {
      const err = validateStep1();
      if (err) {
        setLocalError(err);
        return;
      }
    } else {
      const err = validateStep4();
      if (err) {
        setLocalError(err);
        return;
      }
    }

    setLoading(true);
    try {
      const user = await register({
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        password: formData.password,
        role: role,
        district: formData.district,
        city: formData.city,
        address: formData.address,
        pincode: formData.pincode,

        // Worker rich fields
        primaryTrade: formData.primaryTrade,
        subSkills: formData.subSkills,
        experienceYears: formData.experienceYears,
        toolsOwned: formData.toolsOwned,
        bio: formData.bio,
        certifications: [
          {
            certificationName: formData.certificationName,
            issuingOrganization: formData.issuingOrganization,
            certificateNumber: formData.certificateNumber,
            issueDate: formData.issueDate,
            documentUrl: 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?w=400',
          },
        ],
        aadhaarNumber: formData.aadhaarNumber,
        panNumber: formData.panNumber.toUpperCase(),
        rationCard: formData.rationCard,
        bankName: formData.bankName,
        bankAccount: formData.bankAccount,
        bankIfsc: formData.bankIfsc.toUpperCase(),
        emergencyContactName: formData.emergencyContactName,
        emergencyContactPhone: formData.emergencyContactPhone,
        emergencyContactRelation: formData.emergencyContactRelation,
      });

      if (role === 'WORKER') {
        const appNo = `APP-OD-2026-${String(1000 + (user?.id || 88)).padStart(4, '0')}`;
        setSubmittedApplicationNo(appNo);
        setWizardStep(5); // Success step
      } else {
        navigate('/customer/bookings');
      }
    } catch (err) {
      setLocalError(err.message || 'Registration failed. Please check your credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container py-10 max-w-3xl mx-auto px-4">
      {/* Top Government Seal Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-blue-950 text-amber-400 mb-3 shadow-md border border-amber-500/30">
          <Building2 size={28} />
        </div>
        <div className="text-[11px] font-bold text-blue-900 uppercase tracking-wider mb-1">
          Government of Odisha • Department of Cooperation
        </div>
        <h1 className="text-2xl md:text-3xl font-extrabold text-blue-950">
          Official Cooperative Portal Registration
        </h1>
        <p className="text-xs md:text-sm text-slate-500 mt-1 max-w-lg mx-auto">
          Enroll under the Odisha Cooperative Societies Act, 1962 for verified citizen services or artisan accreditation.
        </p>
      </div>

      <div className="bg-white p-6 md:p-8 rounded-2xl border border-slate-200 shadow-sm space-y-6">
        {/* Role Switcher (Hidden when on success step) */}
        {wizardStep !== 5 && (
          <div>
            <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-2">
              Select Registration Category:
            </label>
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => {
                  setRole('CUSTOMER');
                  setWizardStep(1);
                  setLocalError('');
                }}
                className={`p-3.5 rounded-xl border-2 text-left transition flex items-center gap-3 ${
                  role === 'CUSTOMER'
                    ? 'border-blue-900 bg-blue-50 text-blue-950 ring-2 ring-blue-900/20'
                    : 'border-slate-200 hover:bg-slate-50 text-slate-700'
                }`}
              >
                <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${
                  role === 'CUSTOMER' ? 'bg-blue-900 text-white' : 'bg-slate-100 text-slate-600'
                }`}>
                  <UserCheck size={18} />
                </div>
                <div>
                  <div className="font-bold text-xs">Citizen / Customer</div>
                  <div className="text-[11px] text-slate-500">Book verified cooperative services</div>
                </div>
              </button>

              <button
                type="button"
                onClick={() => {
                  setRole('WORKER');
                  setWizardStep(1);
                  setLocalError('');
                }}
                className={`p-3.5 rounded-xl border-2 text-left transition flex items-center gap-3 ${
                  role === 'WORKER'
                    ? 'border-emerald-700 bg-emerald-50 text-emerald-950 ring-2 ring-emerald-700/20'
                    : 'border-slate-200 hover:bg-slate-50 text-slate-700'
                }`}
              >
                <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${
                  role === 'WORKER' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'
                }`}>
                  <Briefcase size={18} />
                </div>
                <div>
                  <div className="font-bold text-xs">Skilled Worker / Artisan</div>
                  <div className="text-[11px] text-slate-500">Accreditation & direct dispatch</div>
                </div>
              </button>
            </div>
          </div>
        )}

        {/* ── WORKER MULTI-STEP WIZARD PROGRESS BAR ── */}
        {role === 'WORKER' && wizardStep !== 5 && (
          <div className="pt-2 pb-4 border-b border-slate-100">
            <div className="flex items-center justify-between text-xs font-bold mb-2">
              <span className="text-emerald-900 font-mono">
                Step {wizardStep} of 4: {
                  wizardStep === 1 ? 'Personal & Identity' :
                  wizardStep === 2 ? 'Trade Skills & Tools' :
                  wizardStep === 3 ? 'Certifications & NCVT' : 'KYC & Bank Details'
                }
              </span>
              <span className="text-slate-400 text-[11px]">{wizardStep * 25}% Completed</span>
            </div>
            <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
              <div
                className="h-full bg-emerald-600 transition-all duration-300 rounded-full"
                style={{ width: `${wizardStep * 25}%` }}
              />
            </div>

            <div className="grid grid-cols-4 gap-1 mt-3 text-center text-[10px] font-semibold text-slate-500">
              <span className={wizardStep >= 1 ? 'text-emerald-800 font-bold' : ''}>1. Identity</span>
              <span className={wizardStep >= 2 ? 'text-emerald-800 font-bold' : ''}>2. Skills & Tools</span>
              <span className={wizardStep >= 3 ? 'text-emerald-800 font-bold' : ''}>3. Certificate</span>
              <span className={wizardStep >= 4 ? 'text-emerald-800 font-bold' : ''}>4. KYC & Bank</span>
            </div>
          </div>
        )}

        {(localError || error) && (
          <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-red-800 text-xs flex items-center gap-2">
            <AlertCircle size={16} className="shrink-0 text-red-600" />
            <span>{localError || error}</span>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────
            CASE A: SUCCESS STEP (Worker Application Submitted)
           ───────────────────────────────────────────────────────────── */}
        {role === 'WORKER' && wizardStep === 5 && (
          <div className="text-center py-6 space-y-6">
            <div className="w-16 h-16 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center mx-auto shadow-inner border border-emerald-300">
              <CheckCircle2 size={36} />
            </div>

            <div>
              <span className="text-[10px] font-extrabold uppercase tracking-widest px-3 py-1 rounded bg-blue-100 text-blue-900 border border-blue-200">
                Application Received
              </span>
              <h2 className="text-xl md:text-2xl font-bold text-slate-900 mt-2">
                Worker Accreditation Dossier Submitted
              </h2>
              <p className="text-xs sm:text-sm text-slate-600 max-w-lg mx-auto mt-1 leading-relaxed">
                Your application has been forwarded to the <strong>{formData.district} District Labour Cooperative Federation Officer</strong> for physical & credential verification.
              </p>
            </div>

            {/* Official Receipt Box */}
            <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 max-w-md mx-auto text-left text-xs space-y-2">
              <div className="flex justify-between">
                <span className="text-slate-500">Application Number:</span>
                <span className="font-mono font-bold text-blue-950">{submittedApplicationNo}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Applicant Name:</span>
                <span className="font-bold text-slate-800">{formData.name}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Primary Trade:</span>
                <span className="font-bold text-emerald-800">{formData.primaryTrade}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Assigned Cooperative:</span>
                <span className="font-semibold text-slate-800">{formData.district} Labour Cooperative</span>
              </div>
              <div className="flex justify-between border-t border-slate-200 pt-2">
                <span className="text-slate-500">Current Status:</span>
                <span className="gov-stamp text-amber-800 border-amber-400 bg-amber-50">
                  ⏳ UNDER ADMINISTRATIVE REVIEW
                </span>
              </div>
            </div>

            {/* Next Steps Roadmap */}
            <div className="text-left text-xs text-slate-700 bg-blue-50/60 p-4 rounded-xl border border-blue-200 max-w-lg mx-auto space-y-2">
              <strong className="text-blue-950 block">Accreditation Verification Roadmap:</strong>
              <div className="space-y-1.5 text-[11px] text-slate-600">
                <div className="flex items-center gap-2 text-emerald-800 font-semibold">
                  <Check size={14} className="text-emerald-700" />
                  <span>1. Digital Form & KYC Submission: Completed</span>
                </div>
                <div className="flex items-center gap-2 text-blue-900 font-semibold">
                  <Clock size={14} className="text-amber-600" />
                  <span>2. ITI Trade Certificate & Aadhaar Audit: In Progress</span>
                </div>
                <div className="flex items-center gap-2 text-slate-500">
                  <span className="w-3.5 h-3.5 rounded-full border border-slate-300 inline-block text-center text-[9px]">3</span>
                  <span>3. Cooperative Admin Physical Approval & Worker Badge Issuance</span>
                </div>
                <div className="flex items-center gap-2 text-slate-500">
                  <span className="w-3.5 h-3.5 rounded-full border border-slate-300 inline-block text-center text-[9px]">4</span>
                  <span>4. Activation on Live Dispatch Map & Duty Console</span>
                </div>
              </div>
            </div>

            <div className="pt-2">
              <Link
                to="/worker/dashboard"
                className="btn btn-primary w-full max-w-md py-3 text-xs font-bold"
              >
                Proceed to Worker Dashboard & Track Review Status →
              </Link>
            </div>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────
            CASE B: CITIZEN REGISTRATION (1 STEP) OR WORKER STEP 1
           ───────────────────────────────────────────────────────────── */}
        {wizardStep === 1 && (
          <div className="space-y-4">
            <div className="pb-2 border-b border-slate-100">
              <h3 className="font-bold text-sm text-slate-900">
                {role === 'WORKER' ? 'Step 1: Personal & Identity Information' : 'Citizen Account Details'}
              </h3>
              <p className="text-xs text-slate-500">
                {role === 'WORKER'
                  ? 'Legal name and residential details required for cooperative police & federation records.'
                  : 'Enter your details to create your citizen account and book services.'}
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Full Legal Name *
                </label>
                <input
                  type="text"
                  required
                  name="name"
                  placeholder="e.g. Ramesh Kumar"
                  value={formData.name}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Email Address *
                </label>
                <input
                  type="email"
                  required
                  name="email"
                  placeholder="e.g. ramesh@example.com"
                  value={formData.email}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Mobile / WhatsApp Number *
                </label>
                <input
                  type="tel"
                  required
                  name="phone"
                  placeholder="e.g. 9876543210"
                  value={formData.phone}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  District (District Cooperative Federation) *
                </label>
                <select
                  name="district"
                  value={formData.district}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white"
                >
                  <option value="Khordha">Khordha (Bhubaneswar Metro Federation)</option>
                  <option value="Cuttack">Cuttack District Cooperative Society</option>
                  <option value="Puri">Puri Coastal Labour Cooperative</option>
                  <option value="Ganjam">Ganjam (Berhampur Labour Society)</option>
                  <option value="Sambalpur">Sambalpur Regional Directorate</option>
                </select>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  City / Local Town *
                </label>
                <input
                  type="text"
                  required
                  name="city"
                  placeholder="e.g. Saheed Nagar, Bhubaneswar"
                  value={formData.city}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Pincode *
                </label>
                <input
                  type="text"
                  required
                  name="pincode"
                  placeholder="e.g. 751007"
                  value={formData.pincode}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                Full Residential Address *
              </label>
              <textarea
                rows={2}
                required
                name="address"
                placeholder="Plot / House No, Street, Landmark"
                value={formData.address}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Create Password *
                </label>
                <input
                  type="password"
                  required
                  name="password"
                  placeholder="Minimum 6 characters"
                  value={formData.password}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Confirm Password *
                </label>
                <input
                  type="password"
                  required
                  name="confirmPassword"
                  placeholder="Re-type password"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            <div className="pt-3">
              {role === 'WORKER' ? (
                <button
                  type="button"
                  onClick={handleNextStep}
                  className="w-full btn btn-primary py-3 text-xs font-bold flex items-center justify-center gap-2"
                >
                  <span>Proceed to Step 2: Trade Skills & Tools</span>
                  <ChevronRight size={15} />
                </button>
              ) : (
                <button
                  type="button"
                  disabled={loading}
                  onClick={handleSubmit}
                  className="w-full btn btn-primary py-3 text-xs font-bold"
                >
                  {loading ? 'Creating Citizen Account...' : 'Register as Citizen →'}
                </button>
              )}
            </div>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────
            CASE C: WORKER STEP 2 (Trade Skills & Equipment)
           ───────────────────────────────────────────────────────────── */}
        {role === 'WORKER' && wizardStep === 2 && (
          <div className="space-y-4">
            <div className="pb-2 border-b border-slate-100">
              <h3 className="font-bold text-sm text-slate-900">
                Step 2: Trade Skills, Specializations & Tools Owned
              </h3>
              <p className="text-xs text-slate-500">
                Select your primary trade category and sub-skills for smart dispatch matching.
              </p>
            </div>

            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Primary Trade Category *
              </label>
              <select
                name="primaryTrade"
                value={formData.primaryTrade}
                onChange={(e) => {
                  const newTrade = e.target.value;
                  const suggestions = SKILL_SUGGESTIONS[newTrade] || [];
                  setFormData((prev) => ({
                    ...prev,
                    primaryTrade: newTrade,
                    subSkills: suggestions.slice(0, 2),
                  }));
                }}
                className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white font-semibold text-slate-800"
              >
                {TRADES.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.icon} {t.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Sub-Skill Badges Toggle */}
            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                Sub-Specializations & Practical Skills * (Click to select)
              </label>
              <div className="flex flex-wrap gap-2">
                {(SKILL_SUGGESTIONS[formData.primaryTrade] || []).map((skill) => {
                  const isSelected = formData.subSkills.includes(skill);
                  return (
                    <button
                      key={skill}
                      type="button"
                      onClick={() => toggleSubSkill(skill)}
                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition flex items-center gap-1.5 ${
                        isSelected
                          ? 'bg-emerald-800 text-white border-emerald-800 shadow-xs'
                          : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
                      }`}
                    >
                      <span>{isSelected ? '✓' : '+'}</span>
                      <span>{skill}</span>
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Years of Trade Experience *
                </label>
                <select
                  name="experienceYears"
                  value={formData.experienceYears}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white"
                >
                  <option value={1}>1 Year (Apprentice)</option>
                  <option value={2}>2 Years (Junior Artisan)</option>
                  <option value={3}>3 to 5 Years (Skilled Artisan)</option>
                  <option value={6}>6 to 10 Years (Senior Artisan)</option>
                  <option value={12}>10+ Years (Master Artisan)</option>
                </select>
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Working Availability *
                </label>
                <select
                  name="dailyAvailability"
                  value={formData.dailyAvailability}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white"
                >
                  <option value="FULL_TIME">Full-Time (8:00 AM - 8:00 PM)</option>
                  <option value="MORNING_SHIFT">Morning Shift (8:00 AM - 2:00 PM)</option>
                  <option value="EVENING_SHIFT">Evening Shift (2:00 PM - 9:00 PM)</option>
                  <option value="EMERGENCY_24X7">24x7 Emergency Rapid Response Squad</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                Primary Tools & Safety Gear Owned *
              </label>
              <input
                type="text"
                name="toolsOwned"
                required
                placeholder="e.g. Digital Multimeter, Heavy Hammer Drill, Pipe Wrench, Safety Helmet & Gloves"
                value={formData.toolsOwned}
                onChange={handleChange}
                className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                Brief Professional Bio / Background Summary
              </label>
              <textarea
                rows={2}
                name="bio"
                placeholder="Describe your trade background, major projects, or specialties..."
                value={formData.bio}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
              />
            </div>

            <div className="pt-3 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={handlePrevStep}
                className="btn btn-secondary py-2.5 text-xs font-bold flex items-center gap-1"
              >
                <ChevronLeft size={15} /> Back
              </button>
              <button
                type="button"
                onClick={handleNextStep}
                className="btn btn-primary py-2.5 text-xs font-bold flex items-center gap-1"
              >
                <span>Step 3: Certifications & NCVT →</span>
                <ChevronRight size={15} />
              </button>
            </div>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────
            CASE D: WORKER STEP 3 (Trade Certifications)
           ───────────────────────────────────────────────────────────── */}
        {role === 'WORKER' && wizardStep === 3 && (
          <div className="space-y-4">
            <div className="pb-2 border-b border-slate-100">
              <h3 className="font-bold text-sm text-slate-900">
                Step 3: Trade Certifications & NCVT / ITI Credentials
              </h3>
              <p className="text-xs text-slate-500">
                Cooperative federation rules require state or national trade accreditation records.
              </p>
            </div>

            <div>
              <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                Certification Category *
              </label>
              <select
                name="certificationType"
                value={formData.certificationType}
                onChange={handleChange}
                className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white"
              >
                <option value="ITI_NCVT">ITI National Trade Certificate (NCVT / SCVT)</option>
                <option value="NSDC_SKILL_INDIA">NSDC Skill India Pradhan Mantri Kaushal Card</option>
                <option value="STATE_TRADE_GUILD">Odisha State Labour Welfare Board Trade License</option>
                <option value="RPL_PRIOR_LEARNING">Recognition of Prior Learning (RPL) Level 4 Certificate</option>
                <option value="DIPLOMA_POLYTECHNIC">State Polytechnic Technical Diploma</option>
              </select>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Certificate / Course Title *
                </label>
                <input
                  type="text"
                  required
                  name="certificationName"
                  placeholder="e.g. National Trade Certificate — Electrician"
                  value={formData.certificationName}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Certificate / Roll / Registration No. *
                </label>
                <input
                  type="text"
                  required
                  name="certificateNumber"
                  placeholder="e.g. ITI-OD-2022-8821"
                  value={formData.certificateNumber}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Issuing Institute / Training Center *
                </label>
                <input
                  type="text"
                  required
                  name="issuingOrganization"
                  placeholder="e.g. Government ITI Bhubaneswar / NCVT"
                  value={formData.issuingOrganization}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Issue Date / Passing Year *
                </label>
                <input
                  type="date"
                  required
                  name="issueDate"
                  value={formData.issueDate}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            {/* Document Upload Simulation */}
            <div className="p-3.5 bg-slate-50 border border-dashed border-slate-300 rounded-xl text-xs flex items-center justify-between">
              <div className="flex items-center gap-2">
                <FileText size={20} className="text-blue-900" />
                <div>
                  <div className="font-bold text-slate-800">Trade Certificate Scan Copy (Simulated Upload)</div>
                  <div className="text-[11px] text-slate-500">PDF / JPG format up to 5 MB</div>
                </div>
              </div>
              <span className="gov-seal-verified">
                ✓ Document Attached
              </span>
            </div>

            <div className="pt-3 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={handlePrevStep}
                className="btn btn-secondary py-2.5 text-xs font-bold flex items-center gap-1"
              >
                <ChevronLeft size={15} /> Back
              </button>
              <button
                type="button"
                onClick={handleNextStep}
                className="btn btn-primary py-2.5 text-xs font-bold flex items-center gap-1"
              >
                <span>Step 4: Statutory KYC & Bank →</span>
                <ChevronRight size={15} />
              </button>
            </div>
          </div>
        )}

        {/* ─────────────────────────────────────────────────────────────
            CASE E: WORKER STEP 4 (Statutory KYC & Banking)
           ───────────────────────────────────────────────────────────── */}
        {role === 'WORKER' && wizardStep === 4 && (
          <div className="space-y-4">
            <div className="pb-2 border-b border-slate-100">
              <h3 className="font-bold text-sm text-slate-900">
                Step 4: Statutory KYC & Bank Account Details
              </h3>
              <p className="text-xs text-slate-500">
                Required for direct 90% instant pay settlement, ESIC accident coverage, and police verification.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Aadhaar Card Number (12 Digits) *
                </label>
                <input
                  type="text"
                  required
                  name="aadhaarNumber"
                  placeholder="e.g. 5678 1234 9012"
                  value={formData.aadhaarNumber}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  PAN Card Number (10 Characters) *
                </label>
                <input
                  type="text"
                  required
                  name="panNumber"
                  placeholder="e.g. ABCDE1234F"
                  value={formData.panNumber}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono uppercase"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Bank Name *
                </label>
                <input
                  type="text"
                  required
                  name="bankName"
                  placeholder="e.g. State Bank of India"
                  value={formData.bankName}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Bank Account No. *
                </label>
                <input
                  type="password"
                  required
                  name="bankAccount"
                  placeholder="Account Number"
                  value={formData.bankAccount}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Confirm Account No. *
                </label>
                <input
                  type="text"
                  required
                  name="confirmBankAccount"
                  placeholder="Re-type Account No."
                  value={formData.confirmBankAccount}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Bank Branch IFSC Code *
                </label>
                <input
                  type="text"
                  required
                  name="bankIfsc"
                  placeholder="e.g. SBIN0001234"
                  value={formData.bankIfsc}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono uppercase"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Shramik / BPL / Ration Card No. (Optional)
                </label>
                <input
                  type="text"
                  name="rationCard"
                  placeholder="e.g. OD-BPL-2024-8871"
                  value={formData.rationCard}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs font-mono"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Emergency Contact Name *
                </label>
                <input
                  type="text"
                  required
                  name="emergencyContactName"
                  placeholder="e.g. Minati Kumar"
                  value={formData.emergencyContactName}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Emergency Mobile *
                </label>
                <input
                  type="tel"
                  required
                  name="emergencyContactPhone"
                  placeholder="e.g. 9876500000"
                  value={formData.emergencyContactPhone}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-slate-700 uppercase tracking-wider mb-1">
                  Relationship *
                </label>
                <select
                  name="emergencyContactRelation"
                  value={formData.emergencyContactRelation}
                  onChange={handleChange}
                  className="w-full px-3 py-2.5 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs bg-white"
                >
                  <option value="Spouse">Spouse</option>
                  <option value="Parent">Parent</option>
                  <option value="Sibling">Sibling</option>
                  <option value="Child">Child / Dependent</option>
                </select>
              </div>
            </div>

            {/* Legal Undertaking Checkbox */}
            <div className="p-3.5 bg-amber-50/70 border border-amber-300 rounded-xl text-xs space-y-2">
              <label className="flex items-start gap-2.5 cursor-pointer">
                <input
                  type="checkbox"
                  required
                  name="acceptedUndertaking"
                  checked={formData.acceptedUndertaking}
                  onChange={handleChange}
                  className="mt-0.5 w-4 h-4 rounded text-blue-900 focus:ring-blue-900"
                />
                <span className="text-amber-950 leading-relaxed font-medium">
                  <strong>Statutory Declaration:</strong> I hereby declare under the <em>Odisha Cooperative Societies Act, 1962</em> that all trade skills, certificates, and KYC credentials submitted are authentic. I understand my application is subject to physical & police verification by District Cooperative Federation Officers before live dispatch activation.
                </span>
              </label>
            </div>

            <div className="pt-3 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={handlePrevStep}
                className="btn btn-secondary py-2.5 text-xs font-bold flex items-center gap-1"
              >
                <ChevronLeft size={15} /> Back
              </button>
              <button
                type="button"
                disabled={loading}
                onClick={handleSubmit}
                className="btn btn-saffron py-2.5 text-xs font-bold flex items-center gap-2"
              >
                {loading ? 'Submitting Application...' : 'Submit Accreditation Application →'}
              </button>
            </div>
          </div>
        )}

        {/* Existing Member Link */}
        {wizardStep !== 5 && (
          <div className="mt-4 text-center text-xs text-slate-500 border-t border-slate-100 pt-4">
            Already registered on the platform?{' '}
            <Link to="/login" className="font-bold text-blue-900 hover:underline">
              Sign In via SSO Portal →
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
