import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { useLanguage } from '../context/LanguageContext';
import { useAccessibility } from '../context/AccessibilityContext';
import {
  Zap, Droplets, Hammer, Paintbrush, SprayCan, Flower2,
  HeartPulse, Car, Wrench, Home as HomeIcon, Settings, AlertTriangle,
  Building2, ArrowRight, CheckCircle2, ChevronRight,
  ShieldCheck, Sparkles, IndianRupee, PhoneCall,
  Search, Mic, MicOff, MapPin, Check, Clock, ThumbsUp, Snowflake
} from 'lucide-react';
import HomeReviews from '../components/HomeReviews';


export default function Home() {
  const { lang, t } = useLanguage();
  const { isSpeaking, speakText, stopSpeaking } = useAccessibility();
  const navigate = useNavigate();

  const [dbStats, setDbStats] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDistrict, setSelectedDistrict] = useState('Khordha');
  const [activeCategoryFilter, setActiveCategoryFilter] = useState('all');
  const [isListeningMic, setIsListeningMic] = useState(false);

  useEffect(() => {
    api.getDbStats()
      .then((data) => setDbStats(data.stats))
      .catch((err) => console.warn('Live stats fetch fallback:', err.message));
  }, []);

  // 12 Standardized Cooperative Trade Services
  const serviceCategories = [
    {
      id: 1,
      categoryName: 'Electrical',
      key: 'catElectrical',
      descKey: 'descElectrical',
      descFallback: 'Switches, wiring, ceiling fans, MCB tripping & fuse repairs',
      starting: '₹249',
      popular: true,
      count: 48,
      group: 'electrical',
      icon: Zap,
      iconColor: 'text-amber-600 bg-amber-50 border-amber-200'
    },
    {
      id: 2,
      categoryName: 'Plumbing',
      key: 'catPlumbing',
      descKey: 'descPlumbing',
      descFallback: 'Tap leaks, pipe repair, toilet cisterns, tank & motor fittings',
      starting: '₹249',
      popular: true,
      count: 42,
      group: 'plumbing',
      icon: Droplets,
      iconColor: 'text-blue-600 bg-blue-50 border-blue-200'
    },
    {
      id: 6,
      categoryName: 'Appliance Repair',
      key: 'catAppliance',
      descKey: 'descAppliance',
      descFallback: 'AC servicing, gas refills, washing machines & refrigerators',
      starting: '₹349',
      popular: true,
      count: 36,
      group: 'electrical',
      icon: Wrench,
      iconColor: 'text-indigo-600 bg-indigo-50 border-indigo-200'
    },
    {
      id: 3,
      categoryName: 'Carpentry',
      key: 'catCarpentry',
      descKey: 'descCarpentry',
      descFallback: 'Door locks, hinges, wooden furniture repair & assembly',
      starting: '₹299',
      popular: false,
      count: 28,
      group: 'home',
      icon: Hammer,
      iconColor: 'text-amber-700 bg-amber-50 border-amber-200'
    },
    {
      id: 4,
      categoryName: 'Painting',
      key: 'catPainting',
      descKey: 'descPainting',
      descFallback: 'Room repainting, waterproof wall putty & enamel coatings',
      starting: '₹499',
      popular: true,
      count: 32,
      group: 'home',
      icon: Paintbrush,
      iconColor: 'text-purple-600 bg-purple-50 border-purple-200'
    },
    {
      id: 5,
      categoryName: 'Cleaning',
      key: 'catCleaning',
      descKey: 'descCleaning',
      descFallback: 'Deep bathroom cleaning, kitchen degreasing & sofa wash',
      starting: '₹399',
      popular: false,
      count: 25,
      group: 'home',
      icon: SprayCan,
      iconColor: 'text-emerald-600 bg-emerald-50 border-emerald-200'
    },
    {
      id: 7,
      categoryName: 'Gardening',
      key: 'catGardening',
      descKey: 'descGardening',
      descFallback: 'Lawn trimming, potting, plant pruning & terrace gardens',
      starting: '₹249',
      popular: false,
      count: 18,
      group: 'home',
      icon: Flower2,
      iconColor: 'text-green-600 bg-green-50 border-green-200'
    },
    {
      id: 8,
      categoryName: 'Caregiving',
      key: 'catCaregiving',
      descKey: 'descCaregiving',
      descFallback: 'Elderly assistance, patient care & home nursing aides',
      starting: '₹599',
      popular: false,
      count: 15,
      group: 'home',
      icon: HeartPulse,
      iconColor: 'text-rose-600 bg-rose-50 border-rose-200'
    },
    {
      id: 9,
      categoryName: 'Driving',
      key: 'catDriving',
      descKey: 'descDriving',
      descFallback: 'Verified personal drivers for local & outstation trips',
      starting: '₹399',
      popular: false,
      count: 22,
      group: 'home',
      icon: Car,
      iconColor: 'text-sky-600 bg-sky-50 border-sky-200'
    },
    {
      id: 10,
      categoryName: 'Domestic Services',
      key: 'catDomestic',
      descKey: 'descDomestic',
      descFallback: 'General housekeeping, errand support & home upkeep',
      starting: '₹299',
      popular: false,
      count: 30,
      group: 'home',
      icon: HomeIcon,
      iconColor: 'text-orange-600 bg-orange-50 border-orange-200'
    },
    {
      id: 11,
      categoryName: 'Technician Services',
      key: 'catTechnician',
      descKey: 'descTechnician',
      descFallback: 'CCTV installation, WiFi router setup & inverter wiring',
      starting: '₹349',
      popular: false,
      count: 19,
      group: 'electrical',
      icon: Settings,
      iconColor: 'text-slate-600 bg-slate-50 border-slate-200'
    },
    {
      id: 12,
      categoryName: 'Emergency Services',
      key: 'catEmergency',
      descKey: 'descEmergency',
      descFallback: '24/7 rapid dispatch for burst pipes, power outage & lockouts',
      starting: '₹499',
      emergency: true,
      count: 12,
      group: 'emergency',
      icon: AlertTriangle,
      iconColor: 'text-red-600 bg-red-50 border-red-200'
    },
  ];

  const handleVoiceSearch = () => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      alert('Voice search is not supported in this browser. Please use Chrome on mobile or desktop.');
      return;
    }
    const recognition = new SpeechRecognition();
    recognition.lang = lang === 'HI' ? 'hi-IN' : lang === 'OR' ? 'or-IN' : lang === 'BN' ? 'bn-IN' : lang === 'TE' ? 'te-IN' : 'en-IN';
    recognition.interimResults = false;

    setIsListeningMic(true);
    recognition.onresult = (event) => {
      const speechResult = event.results[0][0].transcript;
      setSearchQuery(speechResult);
      setIsListeningMic(false);
      navigate(`/book-service?search=${encodeURIComponent(speechResult)}&district=${encodeURIComponent(selectedDistrict)}`);
    };
    recognition.onerror = () => setIsListeningMic(false);
    recognition.onend = () => setIsListeningMic(false);
    recognition.start();
  };

  const handleUnifiedSearch = (e) => {
    e.preventDefault();
    const params = new URLSearchParams();
    if (selectedDistrict) params.set('district', selectedDistrict);
    if (searchQuery.trim()) params.set('search', searchQuery.trim());
    navigate(`/book-service?${params.toString()}`);
  };

  const filteredCategories = serviceCategories.filter(cat => {
    if (activeCategoryFilter === 'all') return true;
    if (activeCategoryFilter === 'popular') return cat.popular;
    if (activeCategoryFilter === 'emergency') return cat.emergency;
    return cat.group === activeCategoryFilter;
  });

  return (
    <div className="space-y-0 bg-white text-slate-900">
      
      {/* ─────────────────────────────────────────────────────────────
          1. CLEAN, MODERN, LIGHT HERO SECTION
         ───────────────────────────────────────────────────────────── */}
      <section className="relative overflow-hidden bg-gradient-to-b from-[#F8FAFC] via-[#F1F5F9]/50 to-white pt-10 sm:pt-14 pb-14 sm:pb-16 px-4 border-b border-slate-200/80">
        
        {/* Soft Ambient Radial Background Highlights */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[760px] h-[340px] bg-gradient-to-b from-blue-100/60 via-amber-100/30 to-transparent blur-3xl pointer-events-none rounded-full" />

        <div className="relative max-w-4xl mx-auto text-center space-y-4">
          
          {/* Subtle Trust Badge */}
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-200/80 text-blue-900 text-xs font-semibold tracking-wide shadow-2xs">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse shrink-0" />
            <span>Verified Artisans • Fixed Tariffs</span>
          </div>

          {/* Punchy, Clear Headline */}
          <h1 className="text-3xl sm:text-5xl lg:text-6xl font-black tracking-tight leading-[1.14] text-slate-950">
            Expert Repairs.{' '}
            <br className="hidden sm:inline" />
            <span className="bg-gradient-to-r from-blue-800 via-indigo-700 to-emerald-700 bg-clip-text text-transparent">
              Fixed Rates.
            </span>
          </h1>

          {/* Simple, Minimal Subtitle */}
          <p className="text-xs sm:text-sm md:text-base text-slate-600 leading-relaxed max-w-lg mx-auto font-normal">
            Certified electricians, plumbers & mechanics with 30-day warranty and zero surge pricing.
          </p>

          {/* Minimalist Floating Search Capsule */}
          <div className="pt-2 max-w-3xl mx-auto">
            <form
              onSubmit={handleUnifiedSearch}
              className="bg-white p-2 rounded-2xl shadow-xl shadow-slate-200/70 border border-slate-200/90 flex flex-col sm:flex-row items-center gap-2 text-slate-900"
            >
              {/* District Selector */}
              <div className="relative w-full sm:w-52 flex items-center border-b sm:border-b-0 sm:border-r border-slate-200 pb-2 sm:pb-0 sm:pr-2">
                <MapPin className="absolute left-3 w-4 h-4 text-slate-400 pointer-events-none" />
                <select
                  value={selectedDistrict}
                  onChange={(e) => setSelectedDistrict(e.target.value)}
                  className="w-full pl-9 pr-6 py-2.5 bg-slate-50 hover:bg-slate-100/80 text-slate-800 rounded-xl text-xs sm:text-sm font-bold border-0 focus:outline-none focus:ring-2 focus:ring-blue-900 transition cursor-pointer appearance-none"
                >
                  <option value="Khordha">Khordha (Bhubaneswar)</option>
                  <option value="Cuttack">Cuttack</option>
                  <option value="Puri">Puri</option>
                  <option value="Ganjam">Ganjam</option>
                  <option value="Sambalpur">Sambalpur</option>
                  <option value="Balasore">Balasore</option>
                </select>
                <ChevronRight size={13} className="absolute right-3 text-slate-400 pointer-events-none rotate-90" />
              </div>

              {/* Main Issue Search Input */}
              <div className="relative flex-1 w-full flex items-center">
                <Search className="absolute left-3.5 w-4 h-4 text-slate-400 pointer-events-none" />
                <input
                  type="text"
                  placeholder="What needs repair? (e.g. tap leaking, fan sparking, AC cooling)..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-9 py-2.5 bg-slate-50 hover:bg-slate-100/80 focus:bg-white text-slate-900 placeholder:text-slate-400 rounded-xl text-xs sm:text-sm font-medium border-0 focus:outline-none focus:ring-2 focus:ring-blue-900 transition"
                />
                <button
                  type="button"
                  onClick={handleVoiceSearch}
                  className={`absolute right-3 p-1 rounded-lg ${isListeningMic ? 'text-red-600 bg-red-50 animate-pulse' : 'text-slate-400 hover:text-slate-700 hover:bg-slate-200/60'}`}
                  title="Voice Search"
                >
                  {isListeningMic ? <MicOff size={16} /> : <Mic size={16} />}
                </button>
              </div>

              {/* Action Button */}
              <button
                type="submit"
                className="w-full sm:w-auto bg-[#0F294A] hover:bg-blue-900 text-white text-xs sm:text-sm font-bold px-6 py-3 rounded-xl shadow-md hover:shadow-lg transition-all flex items-center justify-center gap-2 shrink-0"
              >
                <span>Find Service</span>
                <ArrowRight size={15} />
              </button>
            </form>
          </div>

          {/* Clean Trust Assurance Strip */}
          <div className="pt-4 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs text-slate-600 font-semibold border-t border-slate-200/80 max-w-2xl mx-auto">
            <div className="flex items-center gap-1.5 text-emerald-700">
              <ShieldCheck size={16} className="text-emerald-600" />
              <span>100% ITI Verified</span>
            </div>
            <div className="flex items-center gap-1.5 text-amber-700">
              <CheckCircle2 size={16} className="text-amber-600" />
              <span>Zero Surge Pricing</span>
            </div>
            <div className="flex items-center gap-1.5 text-blue-700">
              <Sparkles size={16} className="text-blue-600" />
              <span>30-Day Free Warranty</span>
            </div>
            <a
              href="tel:18003457788"
              className="flex items-center gap-1.5 text-slate-700 hover:text-blue-900 transition font-bold pl-2 border-l border-slate-200"
            >
              <PhoneCall size={13} className="text-emerald-600" />
              <span>Toll-Free: <strong className="font-mono text-slate-900">1800-345-7788</strong></span>
            </a>
          </div>

        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          2. STANDARDIZED SERVICES CATALOG (WITH MINIMAL FILTER TABS)
         ───────────────────────────────────────────────────────────── */}
      <section className="py-12 px-4 max-w-6xl mx-auto">
        <div className="text-center max-w-2xl mx-auto mb-8">
          <span className="inline-block text-[11px] font-bold text-blue-900 uppercase tracking-wider px-3 py-1 bg-blue-50 rounded-full mb-2 border border-blue-200">
            Regulated Tariffs
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
            Standardized Trade Services
          </h2>
          <p className="text-xs sm:text-sm text-slate-600 mt-1">
            Official base tariffs for all household trades. Transparent labour rates, zero hidden fees.
          </p>

          {/* Filter Pills */}
          <div className="flex items-center justify-center gap-1.5 flex-wrap mt-5">
            {[
              { id: 'all', label: 'All Services (12)' },
              { id: 'popular', label: '🔥 Popular' },
              { id: 'electrical', label: '⚡ Electrical & AC' },
              { id: 'plumbing', label: '🚰 Plumbing' },
              { id: 'home', label: '🔨 Carpentry & Home' },
              { id: 'emergency', label: '🚨 Emergency 24/7' },
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveCategoryFilter(tab.id)}
                className={`px-3 py-1.5 rounded-full text-xs font-bold transition ${
                  activeCategoryFilter === tab.id
                    ? 'bg-[#0F294A] text-white shadow-xs'
                    : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* 12 Modern Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredCategories.map((cat) => {
            const Icon = cat.icon;
            return (
              <div
                key={cat.id}
                className={`p-5 flex flex-col justify-between rounded-2xl transition-all duration-200 border text-left bg-white shadow-2xs hover:shadow-md ${
                  cat.emergency
                    ? 'border-red-200 hover:border-red-400 bg-gradient-to-b from-white to-red-50/20'
                    : 'border-slate-200/90 hover:border-blue-900'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between mb-3.5">
                    <div className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 border ${cat.iconColor}`}>
                      <Icon size={22} />
                    </div>

                    {cat.popular && (
                      <span className="text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-amber-100 text-amber-900 border border-amber-300">
                        Popular
                      </span>
                    )}
                    {cat.emergency && (
                      <span className="text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-red-600 text-white animate-pulse">
                        24/7 Rapid
                      </span>
                    )}
                  </div>

                  <h3 className="font-extrabold text-base text-slate-900 mb-1 leading-snug">
                    {t(cat.key) || cat.categoryName}
                  </h3>
                  <p className="text-xs text-slate-500 line-clamp-2 mb-4 leading-relaxed">
                    {t(cat.descKey) || cat.descFallback}
                  </p>
                </div>

                <div className="pt-3 border-t border-slate-100 space-y-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-[10px] text-slate-400 block uppercase font-bold tracking-wider">Fixed Base</span>
                      <span className="font-black text-slate-950 text-base font-mono">{cat.starting}</span>
                    </div>
                    <span className="text-[11px] text-emerald-700 font-bold bg-emerald-50 px-2 py-0.5 rounded-md border border-emerald-200">
                      {cat.count} verified pros
                    </span>
                  </div>

                  <Link
                    to={`/book-service?category=${encodeURIComponent(cat.categoryName)}&district=${encodeURIComponent(selectedDistrict)}`}
                    className="w-full bg-[#0F294A] hover:bg-blue-900 text-white rounded-xl py-2.5 px-3 text-xs font-bold text-center flex items-center justify-center gap-1.5 transition shadow-2xs hover:shadow-xs"
                  >
                    <span>Book Service</span>
                    <ArrowRight size={13} />
                  </Link>
                </div>
              </div>
            );
          })}
        </div>

        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-4 text-left">
          {/* Card 1: Transparent Rate Card */}
          <div className="p-5 rounded-2xl bg-gradient-to-br from-slate-900 to-slate-950 text-white border border-slate-800 flex flex-col justify-between shadow-xs">
            <div>
              <div className="flex items-center justify-between gap-2 mb-2.5">
                <span className="inline-flex items-center gap-1 text-[10px] font-extrabold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 px-2.5 py-0.5 rounded-full">
                  <ShieldCheck size={11} />
                  93-2-5 Model
                </span>
                <span className="text-[11px] text-slate-400 font-mono">Labour Capped ₹199-₹349</span>
              </div>
              <h3 className="text-base font-bold text-white mb-1.5">
                Regulated Fixed Rate Card
              </h3>
              <p className="text-xs text-slate-300 leading-relaxed mb-4">
                Know the exact price of every replacement capacitor, PCB, and gas charge upfront. Zero surge pricing and direct 93% living wage artisan payout.
              </p>
            </div>
            <Link
              to="/rate-card"
              className="inline-flex items-center justify-between text-xs font-bold text-emerald-400 hover:text-emerald-300 bg-white/10 hover:bg-white/15 px-4 py-2.5 rounded-xl border border-white/10 transition"
            >
              <span>View Itemized Rate Card</span>
              <ArrowRight size={13} />
            </Link>
          </div>

          {/* Card 2: Foam-Jet AC Showcase & 5-Step Process */}
          <div className="p-5 rounded-2xl bg-gradient-to-br from-blue-950 to-slate-900 text-white border border-blue-900/50 flex flex-col justify-between shadow-xs">
            <div>
              <div className="flex items-center justify-between gap-2 mb-2.5">
                <span className="inline-flex items-center gap-1 text-[10px] font-extrabold uppercase tracking-wider bg-blue-500/20 text-blue-300 border border-blue-500/30 px-2.5 py-0.5 rounded-full">
                  <Snowflake size={11} />
                  Standard Operating Procedure
                </span>
                <span className="text-[11px] text-amber-300 font-bold">30-Day Free Warranty</span>
              </div>
              <h3 className="text-base font-bold text-white mb-1.5">
                Foam-Jet AC Deep Overhaul Process
              </h3>
              <p className="text-xs text-slate-300 leading-relaxed mb-4">
                High-pressure coil wash with leak-proof protection apron, calibrated digital gas audit, and delta-T cold airflow verification.
              </p>
            </div>
            <Link
              to="/services/1"
              className="inline-flex items-center justify-between text-xs font-bold text-blue-300 hover:text-blue-200 bg-white/10 hover:bg-white/15 px-4 py-2.5 rounded-xl border border-white/10 transition"
            >
              <span>Explore 5-Step AC Process</span>
              <ArrowRight size={13} />
            </Link>
          </div>
        </div>

        <div className="text-center mt-8">
          <Link
            to="/services"
            className="inline-flex items-center gap-2 border border-slate-300 hover:border-slate-400 bg-white text-slate-800 font-bold text-xs px-6 py-2.5 rounded-xl shadow-2xs hover:bg-slate-50 transition"
          >
            <span>Browse All 47 Granular Trade Services</span>
            <ArrowRight size={14} />
          </Link>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          3. HOW IT WORKS (SIMPLE 3-STEP GUIDE)
         ───────────────────────────────────────────────────────────── */}
      <section className="py-14 bg-slate-50/80 border-y border-slate-200/80 px-4">
        <div className="max-w-5xl mx-auto">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <span className="inline-block text-[11px] font-bold text-emerald-900 uppercase tracking-wider px-3 py-1 bg-emerald-100 rounded-full mb-2">
              Transparent & Simple
            </span>
            <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
              How Shram Setu Works
            </h2>
            <p className="text-xs sm:text-sm text-slate-600 mt-1">
              Book skilled cooperative artisans in 3 easy steps with zero surge pricing.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
            
            {/* Step 1 */}
            <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-2xs">
              <div className="w-10 h-10 rounded-xl bg-blue-900 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                1
              </div>
              <h3 className="font-extrabold text-base text-slate-900 mb-1.5">1. Select Your Repair</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Search your problem (e.g. leaking tap or AC repair). View transparent fixed base tariffs upfront—no hidden charges.
              </p>
            </div>

            {/* Step 2 */}
            <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-2xs">
              <div className="w-10 h-10 rounded-xl bg-amber-500 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                2
              </div>
              <h3 className="font-extrabold text-base text-slate-900 mb-1.5">2. Nearby Pro Dispatched</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                An ITI-certified, police background-verified cooperative technician arrives at your door at the requested time.
              </p>
            </div>

            {/* Step 3 */}
            <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-2xs">
              <div className="w-10 h-10 rounded-xl bg-emerald-700 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                3
              </div>
              <h3 className="font-extrabold text-base text-slate-900 mb-1.5">3. Pay Fixed Rate & Relax</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Pay standard regulated rates via UPI or cash only after job completion. Enjoy our 30-day free repair warranty.
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          4. COMPARISON: SHRAM SETU VS PRIVATE APPS (EASY TO UNDERSTAND)
         ───────────────────────────────────────────────────────────── */}
      <section className="py-14 bg-white px-4 border-b border-slate-200/80">
        <div className="max-w-4xl mx-auto text-center">
          <span className="inline-block text-[11px] font-bold text-amber-900 uppercase tracking-wider px-3 py-1 bg-amber-100 rounded-full mb-2">
            Why Cooperative
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
            Cooperative Standards vs. Private Aggregators
          </h2>
          <p className="text-xs sm:text-sm text-slate-600 mt-1 max-w-xl mx-auto">
            Fair tariffs for citizens, dignified earnings and direct social security for skilled workers.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-8 text-left">
            
            {/* Shram Setu Card */}
            <div className="p-6 rounded-2xl bg-blue-50/50 border-2 border-blue-600/60 shadow-xs relative overflow-hidden">
              <div className="absolute top-3 right-3 px-2 py-0.5 rounded text-[10px] font-extrabold bg-blue-900 text-white">
                SHRAM SETU
              </div>
              <h3 className="font-extrabold text-lg text-blue-950 mb-4">Labour Cooperative Model</h3>
              <ul className="space-y-3 text-xs text-slate-700">
                <li className="flex items-center gap-2.5">
                  <div className="w-4 h-4 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <Check size={12} />
                  </div>
                  <span><strong>Regulated Fixed Tariffs:</strong> Zero surge pricing during rains, rush hours, or holidays.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <div className="w-4 h-4 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <Check size={12} />
                  </div>
                  <span><strong>100% ITI Certified:</strong> Biometric Aadhaar & police background verification.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <div className="w-4 h-4 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <Check size={12} />
                  </div>
                  <span><strong>100% Fair Pay to Artisans:</strong> Direct social security & accident insurance.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <div className="w-4 h-4 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <Check size={12} />
                  </div>
                  <span><strong>30-Day Free Warranty:</strong> Dedicated nodal dispute & re-repair desk.</span>
                </li>
              </ul>
            </div>

            {/* Commercial Apps Card */}
            <div className="p-6 rounded-2xl bg-slate-50 border border-slate-200 text-slate-500 shadow-2xs">
              <div className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">
                Commercial Gig Apps
              </div>
              <h3 className="font-extrabold text-lg text-slate-700 mb-4">Private Aggregators</h3>
              <ul className="space-y-3 text-xs text-slate-500">
                <li className="flex items-center gap-2.5">
                  <span className="text-red-500 font-bold shrink-0">✕</span>
                  <span>Unpredictable surge pricing up to 2x during peak weather or emergency hours.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <span className="text-red-500 font-bold shrink-0">✕</span>
                  <span>Heavy commissions (20% to 30%) deducted from workers' hard-earned fees.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <span className="text-red-500 font-bold shrink-0">✕</span>
                  <span>Often gig workers with self-proclaimed experience and no trade certifications.</span>
                </li>
                <li className="flex items-center gap-2.5">
                  <span className="text-red-500 font-bold shrink-0">✕</span>
                  <span>Complex bot-based customer care with difficult warranty claims.</span>
                </li>
              </ul>
            </div>

          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          5. COMMUNITY REVIEWS: CITIZEN & WORKER VOICES
         ───────────────────────────────────────────────────────────── */}
      <HomeReviews />

      {/* ─────────────────────────────────────────────────────────────
          6. PHONE BOOKING & ASSISTED KIOSK BANNER
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-[#FFFDF7] border-b border-amber-200/70 px-4">
        <div className="max-w-5xl mx-auto p-6 sm:p-7 rounded-2xl bg-white border border-amber-200 shadow-xs flex flex-col md:flex-row items-center justify-between gap-5 text-left">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-xl bg-amber-500 text-white flex items-center justify-center shrink-0 shadow-xs">
              <PhoneCall size={24} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] font-extrabold uppercase px-2 py-0.5 rounded bg-amber-100 text-amber-900">
                Assisted Phone Booking
              </span>
              <h3 className="text-lg font-extrabold text-slate-900">
                Prefer to book by phone? Call our Toll-Free Helpline
              </h3>
              <p className="text-xs text-slate-600 max-w-xl leading-relaxed">
                Dial <strong className="font-mono text-slate-900">1800-345-7788</strong> (toll-free, 8 AM to 8 PM) or visit your nearest Gram Panchayat Mo Seva Kendra / CSC kiosk for in-person assisted bookings.
              </p>
            </div>
          </div>

          <div className="shrink-0 w-full md:w-auto flex flex-col sm:flex-row gap-2.5">
            <a
              href="tel:18003457788"
              className="btn bg-[#0F294A] hover:bg-blue-900 text-white text-xs font-bold px-5 py-2.5 rounded-xl shadow-xs flex items-center justify-center gap-1.5"
            >
              <PhoneCall size={14} />
              <span>Call 1800-345-7788</span>
            </a>
            <Link
              to="/help"
              className="btn bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 text-xs font-bold px-4 py-2.5 rounded-xl transition flex items-center justify-center gap-1"
            >
              <span>Kiosk Directory</span>
              <ChevronRight size={14} />
            </Link>
          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          6. LIVE COOPERATIVE STATS
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-slate-900 text-white px-4">
        <div className="max-w-4xl mx-auto text-center">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="p-4 rounded-xl bg-white/5 border border-white/10">
              <div className="text-2xl sm:text-3xl font-black text-amber-400 font-mono">
                {dbStats?.verifiedWorkers || 50}+
              </div>
              <div className="text-xs text-slate-300 font-medium mt-1">Verified Artisans</div>
            </div>

            <div className="p-4 rounded-xl bg-white/5 border border-white/10">
              <div className="text-2xl sm:text-3xl font-black text-white font-mono">
                12
              </div>
              <div className="text-xs text-slate-300 font-medium mt-1">Trade Specializations</div>
            </div>

            <div className="p-4 rounded-xl bg-white/5 border border-white/10">
              <div className="text-2xl sm:text-3xl font-black text-emerald-400 font-mono">
                30
              </div>
              <div className="text-xs text-slate-300 font-medium mt-1">Districts Covered</div>
            </div>

            <div className="p-4 rounded-xl bg-white/5 border border-white/10">
              <div className="text-2xl sm:text-3xl font-black text-amber-300 font-mono">
                99.4%
              </div>
              <div className="text-xs text-slate-300 font-medium mt-1">Citizen Satisfaction</div>
            </div>
          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          7. ARTISAN REGISTRATION CALLOUT
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-white px-4">
        <div className="max-w-4xl mx-auto p-6 sm:p-7 rounded-2xl bg-gradient-to-r from-amber-500 via-amber-600 to-orange-600 text-white shadow-md flex flex-col md:flex-row items-center justify-between gap-5 text-left">
          <div className="space-y-1">
            <span className="inline-block px-2.5 py-0.5 rounded-full bg-white/20 text-white text-[10px] font-black uppercase tracking-wider">
              Artisan Cooperative Membership
            </span>
            <h3 className="text-xl sm:text-2xl font-extrabold leading-tight">
              Are you an ITI or skilled trade artisan?
            </h3>
            <p className="text-xs text-amber-100 max-w-lg leading-relaxed">
              Join your regional Labour Cooperative. Get regular bookings, guaranteed regulated tariffs, ESIC health coverage, and zero agency exploitation.
            </p>
          </div>

          <div className="shrink-0 w-full md:w-auto">
            <Link
              to="/register?role=worker"
              className="w-full md:w-auto btn bg-slate-950 hover:bg-black text-white text-xs font-black px-6 py-3 rounded-xl shadow-md flex items-center justify-center gap-2 border border-white/20"
            >
              <span>Join as an Artisan</span>
              <ArrowRight size={14} />
            </Link>
          </div>
        </div>
      </section>

    </div>
  );
}
