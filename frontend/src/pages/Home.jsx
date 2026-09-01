import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { useLanguage } from '../context/LanguageContext';
import { useAccessibility } from '../context/AccessibilityContext';
import {
  Zap, Droplets, Hammer, Paintbrush, SprayCan, Flower2,
  HeartPulse, Car, Wrench, Home as HomeIcon, Settings, AlertTriangle,
  Building2, ArrowRight, CheckCircle2, ChevronRight,
  ShieldCheck, Sparkles, IndianRupee, PhoneCall, Landmark,
  Volume2, VolumeX, Search, Mic, MicOff, Radio, Users
} from 'lucide-react';

export default function Home() {
  const { lang, t } = useLanguage();
  const { isSpeaking, speakText, stopSpeaking } = useAccessibility();
  const navigate = useNavigate();

  const [dbStats, setDbStats] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDistrict, setSelectedDistrict] = useState('Khordha');
  const [selectedTrade, setSelectedTrade] = useState('');
  const [isListeningMic, setIsListeningMic] = useState(false);

  useEffect(() => {
    api.getDbStats()
      .then((data) => setDbStats(data.stats))
      .catch((err) => console.warn('Live stats fetch fallback:', err.message));
  }, []);

  // 12 Standardized Cooperative Trade Services
  const serviceCategories = [
    { icon: Zap, key: 'catElectrical', categoryName: 'Electrical', descKey: 'descElectrical', starting: '₹249', popular: true, count: 48, id: 1, iconColor: 'text-amber-600 bg-amber-50' },
    { icon: Droplets, key: 'catPlumbing', categoryName: 'Plumbing', descKey: 'descPlumbing', starting: '₹249', popular: true, count: 42, id: 2, iconColor: 'text-blue-600 bg-blue-50' },
    { icon: Wrench, key: 'catAppliance', categoryName: 'Appliance Repair', descKey: 'descAppliance', starting: '₹349', popular: true, count: 36, id: 6, iconColor: 'text-indigo-600 bg-indigo-50' },
    { icon: Hammer, key: 'catCarpentry', categoryName: 'Carpentry', descKey: 'descCarpentry', starting: '₹299', popular: false, count: 28, id: 3, iconColor: 'text-yellow-700 bg-yellow-50' },
    { icon: Paintbrush, key: 'catPainting', categoryName: 'Painting', descKey: 'descPainting', starting: '₹499', popular: true, count: 32, id: 4, iconColor: 'text-purple-600 bg-purple-50' },
    { icon: SprayCan, key: 'catCleaning', categoryName: 'Cleaning', descKey: 'descCleaning', starting: '₹399', popular: false, count: 25, id: 5, iconColor: 'text-emerald-600 bg-emerald-50' },
    { icon: Flower2, key: 'catGardening', categoryName: 'Gardening', descKey: 'descGardening', starting: '₹249', popular: false, count: 18, id: 7, iconColor: 'text-green-600 bg-green-50' },
    { icon: HeartPulse, key: 'catCaregiving', categoryName: 'Caregiving', descKey: 'descCaregiving', starting: '₹599', popular: false, count: 15, id: 8, iconColor: 'text-rose-600 bg-rose-50' },
    { icon: Car, key: 'catDriving', categoryName: 'Driving', descKey: 'descDriving', starting: '₹399', popular: false, count: 22, id: 9, iconColor: 'text-sky-600 bg-sky-50' },
    { icon: HomeIcon, key: 'catDomestic', categoryName: 'Domestic Services', descKey: 'descDomestic', starting: '₹299', popular: false, count: 30, id: 10, iconColor: 'text-orange-600 bg-orange-50' },
    { icon: Settings, key: 'catTechnician', categoryName: 'Technician Services', descKey: 'descTechnician', starting: '₹349', popular: false, count: 19, id: 11, iconColor: 'text-slate-600 bg-slate-50' },
    { icon: AlertTriangle, key: 'catEmergency', categoryName: 'Emergency Services', descKey: 'descEmergency', starting: '₹499', emergency: true, count: 12, id: 12, iconColor: 'text-red-600 bg-red-50' },
  ];

  const handleHeroSpeech = () => {
    if (isSpeaking) {
      stopSpeaking();
      return;
    }
    const currentText = {
      EN: "Welcome to Shram Setu, the official Government Cooperative Labour Services Portal. Verified skills, fair wages, zero surge pricing, and direct social security for all artisans. You can book an electrician, plumber, carpenter, or appliance mechanic online or dial toll free 1800-345-7788.",
      HI: "श्रम सेतु में आपका स्वागत है। यह सरकारी श्रम सहकारी सेवा पोर्टल है। प्रमाणित कारीगर, उचित सरकारी दरें, शून्य अतिरिक्त शुल्क और 100% सामाजिक सुरक्षा। आप ऑनलाइन सेवा बुक कर सकते हैं या टोल-फ्री 1800-345-7788 पर कॉल करें।",
      OR: "ଶ୍ରମ ସେତୁ ପୋର୍ଟାଲକୁ ସ୍ୱାଗତ। ଏହା ସରକାରୀ ଶ୍ରମ ସମବାୟ ମହାସଂଘର ଏକ ପ୍ରୟାସ। ପ୍ରମାଣିତ ଶ୍ରମିକ, ସରକାରୀ ଦର ଏବଂ ସାମାଜିକ ସୁରକ୍ଷା। ସେବା ବୁକ୍ କରିବା ପାଇଁ ଟୋଲ୍ ଫ୍ରି ୧୮୦୦-୩୪୫-୭୭୮୮ ଡାଏଲ କରନ୍ତୁ।",
      BN: "শ্রম সেতুতে স্বাগতম। এটি সরকারি সমবায় শ্রম সেবা পোর্টাল। যাচাইকৃত কর্মী, ন্যায্য সরকারি মূল্য এবং সামাজিক সুরক্ষা। সেবা বুক করতে ১৮০০-৩৪৫-৭৭৮৮ নম্বরে কল করুন।",
      TE: "శ్రమ్ సేతుకు స్వాగతం. ఇది ప్రభుత్వ సహకార కార్మిక సేవల పోర్టల్. ధృవీకరించబడిన నైపుణ్యాలు మరియు సామాజిక భద్రత. సేవను బుక్ చేయడానికి టోల్ ఫ్రీ 1800-345-7788 కు కాల్ చేయండి."
    };
    speakText(currentText[lang] || currentText.EN);
  };

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
      navigate(`/services?search=${encodeURIComponent(speechResult)}`);
    };
    recognition.onerror = () => setIsListeningMic(false);
    recognition.onend = () => setIsListeningMic(false);
    recognition.start();
  };

  const handleUnifiedSearch = (e) => {
    e.preventDefault();
    const params = new URLSearchParams();
    if (selectedTrade) params.set('category', selectedTrade);
    if (selectedDistrict) params.set('district', selectedDistrict);
    if (searchQuery.trim()) params.set('search', searchQuery.trim());

    navigate(`/book-service?${params.toString()}`);
  };

  return (
    <div className="space-y-0 bg-[#F8FAFC]">
      {/* ─────────────────────────────────────────────────────────────
          1. TRICOLOR TOP STRIPE & OFFICIAL LIVE NOTICE BAR
         ───────────────────────────────────────────────────────────── */}
      <div className="h-1 w-full bg-gradient-to-r from-[#FF9933] via-white to-[#138808]" />
      
      <div className="bg-[#0A1931] border-b border-white/10 text-white text-xs py-2 px-4">
        <div className="max-w-6xl mx-auto flex items-center justify-between gap-3 overflow-hidden">
          <div className="flex items-center gap-2 shrink-0">
            <span className="inline-flex items-center gap-1 bg-red-600 text-white font-bold px-2 py-0.5 rounded text-[10px] uppercase tracking-wider animate-pulse">
              <Radio size={12} /> {t('tickerLabel')}
            </span>
          </div>

          <div className="flex-1 truncate text-[11px] text-blue-100 font-medium">
            <span>{t('tickerText')}</span>
          </div>

          <div className="hidden sm:flex items-center gap-2 shrink-0 text-[11px] text-amber-300 font-bold">
            <PhoneCall size={13} />
            <span>{t('tollFreeLabel')}: <strong className="text-white font-mono">1800-345-7788</strong></span>
          </div>
        </div>
      </div>

      {/* ─────────────────────────────────────────────────────────────
          2. MINIMALIST HERO & UNIFIED SEARCH CONSOLE
         ───────────────────────────────────────────────────────────── */}
      <section className="bg-gradient-to-b from-[#0A1931] via-[#102A45] to-[#153457] text-white pt-10 pb-12 px-4 border-b border-amber-500/20">
        <div className="max-w-4xl mx-auto text-center space-y-4">
          
          {/* Government Authority Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white/10 border border-white/15 text-amber-300 text-xs font-bold uppercase tracking-wider shadow-xs">
            <Landmark size={14} className="text-amber-400 shrink-0" />
            <span>{t('portalSubHeader')}</span>
          </div>

          {/* Clean Main Headline */}
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-extrabold tracking-tight leading-tight text-white">
            {t('heroTitlePart1')} <br className="hidden sm:inline" />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-amber-400 to-amber-200">
              {t('heroTitlePart2')}
            </span>
          </h1>

          <p className="text-xs sm:text-sm md:text-base text-blue-100/90 leading-relaxed max-w-2xl mx-auto">
            {t('heroSubtitle')}
          </p>

          {/* Unified Search & Booking Bar */}
          <div className="pt-3 max-w-3xl mx-auto">
            <form
              onSubmit={handleUnifiedSearch}
              className="bg-white p-2 sm:p-2.5 rounded-2xl shadow-2xl border-2 border-amber-400/80 grid grid-cols-1 sm:grid-cols-12 gap-2 text-gray-900"
            >
              {/* Trade Selector */}
              <div className="sm:col-span-4">
                <select
                  value={selectedTrade}
                  onChange={(e) => setSelectedTrade(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 text-gray-900 rounded-xl text-xs font-bold border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-900"
                >
                  <option value="">{t('allServicesOption')}</option>
                  <option value="Electrical">⚡ {t('catElectrical')}</option>
                  <option value="Plumbing">🚰 {t('catPlumbing')}</option>
                  <option value="Appliance Repair">🔧 {t('catAppliance')}</option>
                  <option value="Carpentry">🔨 {t('catCarpentry')}</option>
                  <option value="Painting">🎨 {t('catPainting')}</option>
                  <option value="Cleaning">🧹 {t('catCleaning')}</option>
                  <option value="Gardening">🌿 {t('catGardening')}</option>
                  <option value="Caregiving">🩺 {t('catCaregiving')}</option>
                  <option value="Driving">🚗 {t('catDriving')}</option>
                  <option value="Domestic Services">🏠 {t('catDomestic')}</option>
                  <option value="Technician Services">⚙️ {t('catTechnician')}</option>
                  <option value="Emergency Services">🚨 {t('catEmergency')}</option>
                </select>
              </div>

              {/* District Selector */}
              <div className="sm:col-span-3">
                <select
                  value={selectedDistrict}
                  onChange={(e) => setSelectedDistrict(e.target.value)}
                  className="w-full p-2.5 bg-gray-50 text-gray-900 rounded-xl text-xs font-bold border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-900"
                >
                  <option value="Khordha">Khordha (Bhubaneswar)</option>
                  <option value="Cuttack">Cuttack</option>
                  <option value="Puri">Puri</option>
                  <option value="Ganjam">Ganjam</option>
                </select>
              </div>

              {/* Keyword / Voice Input */}
              <div className="sm:col-span-3">
                <div className="relative">
                  <input
                    type="text"
                    placeholder={t('searchIssuePlaceholder')}
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-3 pr-8 py-2.5 bg-gray-50 text-gray-900 rounded-xl text-xs font-semibold border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-900"
                  />
                  <button
                    type="button"
                    onClick={handleVoiceSearch}
                    className={`absolute inset-y-0 right-0 pr-2.5 flex items-center ${isListeningMic ? 'text-red-600 animate-pulse' : 'text-gray-400 hover:text-blue-900'}`}
                    title={t('voiceSearchTitle')}
                  >
                    {isListeningMic ? <MicOff size={16} /> : <Mic size={16} />}
                  </button>
                </div>
              </div>

              {/* Submit Button */}
              <div className="sm:col-span-2">
                <button
                  type="submit"
                  className="w-full btn btn-saffron text-xs font-extrabold py-2.5 rounded-xl shadow-md flex items-center justify-center gap-1"
                >
                  <Search size={14} />
                  <span>{t('searchBtn')}</span>
                </button>
              </div>
            </form>
          </div>

          {/* Quick Direct Actions for Non-Typing Citizens */}
          <div className="pt-2 flex flex-wrap items-center justify-center gap-3 text-xs">
            {/* Call Helpline Button */}
            <a
              href="tel:18003457788"
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-blue-950 font-extrabold shadow-md transition"
            >
              <PhoneCall size={15} />
              <span>{t('callBookingTag')}: 1800-345-7788</span>
            </a>

            {/* Read aloud button */}
            <button
              type="button"
              onClick={handleHeroSpeech}
              className={`inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold transition border ${
                isSpeaking
                  ? 'bg-white text-blue-950 font-black'
                  : 'bg-white/10 hover:bg-white/20 text-white border-white/20'
              }`}
            >
              {isSpeaking ? <VolumeX size={15} className="text-red-600" /> : <Volume2 size={15} />}
              <span>{isSpeaking ? t('stopVoice') : t('listenVoice')}</span>
            </button>
          </div>

        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          3. 12 PUBLIC COOPERATIVE SERVICES (SINGLE CLEAN DIRECTORY)
         ───────────────────────────────────────────────────────────── */}
      <section className="py-12 px-4 max-w-6xl mx-auto">
        <div className="text-center max-w-2xl mx-auto mb-8">
          <span className="inline-block text-[11px] font-bold text-blue-900 uppercase tracking-wider px-3 py-1 bg-blue-100 rounded-full mb-1.5">
            {t('secServices')}
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-gray-900">
            {t('secServices')}
          </h2>
          <p className="text-xs sm:text-sm text-gray-600 mt-1">
            {t('secServicesSub')}
          </p>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3.5 sm:gap-4">
          {serviceCategories.map((cat, idx) => {
            const Icon = cat.icon;
            return (
              <div
                key={idx}
                className={`p-4 sm:p-5 flex flex-col justify-between rounded-2xl transition border text-left bg-white shadow-xs hover:shadow-md ${
                  cat.emergency
                    ? 'border-red-300 bg-red-50/30 hover:border-red-500'
                    : 'border-gray-200 hover:border-blue-900'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <div className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 shadow-2xs ${cat.iconColor}`}>
                      <Icon size={22} />
                    </div>

                    {cat.popular && (
                      <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-100 text-amber-900 border border-amber-300">
                        Popular
                      </span>
                    )}
                    {cat.emergency && (
                      <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-red-600 text-white animate-pulse">
                        24/7
                      </span>
                    )}
                  </div>

                  <h3 className="font-extrabold text-sm sm:text-base text-gray-900 mb-1 leading-snug">
                    {t(cat.key)}
                  </h3>
                  <p className="text-[11px] text-gray-500 line-clamp-2 mb-3">
                    {t(cat.descKey)}
                  </p>
                </div>

                <div className="pt-3 border-t border-gray-100 space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <div>
                      <span className="text-[10px] text-gray-400 block uppercase font-bold">{t('startingAt')}</span>
                      <span className="font-extrabold text-blue-950 text-base font-mono">{cat.starting}</span>
                    </div>
                    <span className="text-[10px] text-green-700 font-bold bg-green-50 px-2 py-0.5 rounded border border-green-200">
                      {cat.count} {t('verifiedArtisans')}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-1.5 pt-1">
                    <Link
                      to={`/find-worker?skill=${encodeURIComponent(cat.categoryName)}`}
                      className="btn btn-secondary btn-sm text-[11px] font-bold p-1 text-center"
                    >
                      {t('viewArtisansBtn')}
                    </Link>
                    <Link
                      to={`/book-service?category=${encodeURIComponent(cat.categoryName)}`}
                      className="btn btn-primary btn-sm text-[11px] font-bold p-1 text-center"
                    >
                      {t('bookBtn')}
                    </Link>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        <div className="text-center mt-6">
          <Link
            to="/services"
            className="btn btn-secondary text-xs font-bold inline-flex items-center gap-2 border-blue-900 text-blue-950 px-6 py-2.5"
          >
            <span>{t('viewAllTariffsBtn')}</span>
            <ArrowRight size={14} />
          </Link>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          4. HOW IT WORKS (SIMPLE 3-STEP CITIZEN GUIDE)
         ───────────────────────────────────────────────────────────── */}
      <section className="py-14 bg-white border-y border-gray-200 px-4">
        <div className="max-w-5xl mx-auto">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <span className="inline-block text-[11px] font-bold text-green-900 uppercase tracking-wider px-3 py-1 bg-green-100 rounded-full mb-1.5">
              {t('howItWorksBadge')}
            </span>
            <h2 className="text-2xl sm:text-3xl font-extrabold text-gray-900">
              {t('howItWorksTitle')}
            </h2>
            <p className="text-xs sm:text-sm text-gray-600 mt-1">
              {t('howItWorksSub')}
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
            {/* Step 1 */}
            <div className="p-6 rounded-2xl bg-gray-50 border border-gray-200">
              <div className="w-10 h-10 rounded-xl bg-blue-950 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                1
              </div>
              <h3 className="font-extrabold text-base text-gray-900 mb-1.5">{t('step1Title')}</h3>
              <p className="text-xs text-gray-600 leading-relaxed">
                {t('step1Desc')}
              </p>
            </div>

            {/* Step 2 */}
            <div className="p-6 rounded-2xl bg-gray-50 border border-gray-200">
              <div className="w-10 h-10 rounded-xl bg-amber-500 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                2
              </div>
              <h3 className="font-extrabold text-base text-gray-900 mb-1.5">{t('step2Title')}</h3>
              <p className="text-xs text-gray-600 leading-relaxed">
                {t('step2Desc')}
              </p>
            </div>

            {/* Step 3 */}
            <div className="p-6 rounded-2xl bg-gray-50 border border-gray-200">
              <div className="w-10 h-10 rounded-xl bg-green-700 text-white flex items-center justify-center font-extrabold text-base mb-3 shadow-xs">
                3
              </div>
              <h3 className="font-extrabold text-base text-gray-900 mb-1.5">{t('step3Title')}</h3>
              <p className="text-xs text-gray-600 leading-relaxed">
                {t('step3Desc')}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          5. 4 PILLARS OF CITIZEN ASSURANCE & SOCIAL SECURITY
         ───────────────────────────────────────────────────────────── */}
      <section className="py-12 bg-[#F8FAFC] px-4 border-b border-gray-200">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-left">
            
            {/* Pillar 1: Verified */}
            <div className="p-5 rounded-2xl bg-white border border-gray-200 shadow-xs">
              <div className="w-10 h-10 rounded-xl bg-green-100 text-green-800 flex items-center justify-center font-bold mb-3">
                <ShieldCheck size={22} />
              </div>
              <h4 className="font-extrabold text-sm text-gray-900">{t('pillar1Title')}</h4>
              <p className="text-xs text-gray-600 mt-1">{t('pillar1Desc')}</p>
            </div>

            {/* Pillar 2: Fixed Govt Rate */}
            <div className="p-5 rounded-2xl bg-white border border-gray-200 shadow-xs">
              <div className="w-10 h-10 rounded-xl bg-amber-100 text-amber-800 flex items-center justify-center font-bold mb-3">
                <IndianRupee size={22} />
              </div>
              <h4 className="font-extrabold text-sm text-gray-900">{t('pillar2Title')}</h4>
              <p className="text-xs text-gray-600 mt-1">{t('pillar2Desc')}</p>
            </div>

            {/* Pillar 3: 7-Day Guarantee */}
            <div className="p-5 rounded-2xl bg-white border border-gray-200 shadow-xs">
              <div className="w-10 h-10 rounded-xl bg-blue-100 text-blue-800 flex items-center justify-center font-bold mb-3">
                <CheckCircle2 size={22} />
              </div>
              <h4 className="font-extrabold text-sm text-gray-900">{t('guaranteeTitle')}</h4>
              <p className="text-xs text-gray-600 mt-1">{t('guaranteeDesc')}</p>
            </div>

            {/* Pillar 4: Social Security */}
            <div className="p-5 rounded-2xl bg-white border border-gray-200 shadow-xs">
              <div className="w-10 h-10 rounded-xl bg-rose-100 text-rose-800 flex items-center justify-center font-bold mb-3">
                <HeartPulse size={22} />
              </div>
              <h4 className="font-extrabold text-sm text-gray-900">{t('pillar3Title')}</h4>
              <p className="text-xs text-gray-600 mt-1">{t('pillar3Desc')}</p>
            </div>

          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          6. PANCHAYAT CSC / MO SEVA KENDRA KIOSK SUPPORT
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-[#FFFBF0] border-b border-amber-200 px-4">
        <div className="max-w-5xl mx-auto p-6 sm:p-7 rounded-3xl bg-white border-2 border-amber-300 shadow-xs flex flex-col md:flex-row items-center justify-between gap-5 text-left">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-2xl bg-blue-950 text-amber-300 flex items-center justify-center shrink-0 shadow-xs">
              <Building2 size={26} />
            </div>
            <div className="space-y-0.5">
              <span className="text-[10px] font-extrabold uppercase px-2 py-0.5 rounded bg-blue-100 text-blue-950">
                {t('cscBookingTag')}
              </span>
              <h3 className="text-lg font-extrabold text-gray-900">{t('cscBookingTitle')}</h3>
              <p className="text-xs text-gray-600 max-w-xl leading-relaxed">
                {t('cscBookingDesc')}
              </p>
            </div>
          </div>

          <div className="shrink-0 w-full md:w-auto">
            <Link
              to="/help"
              className="w-full md:w-auto btn btn-primary text-xs font-bold px-5 py-2.5 rounded-xl shadow-xs flex items-center justify-center gap-1.5"
            >
              <span>{t('cscBookingSub')}</span>
              <ChevronRight size={15} />
            </Link>
          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          7. LIVE COOPERATIVE METRICS & SOCIAL IMPACT
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-gradient-to-r from-[#0A1931] via-[#152A55] to-[#1E3A8A] text-white px-4">
        <div className="max-w-5xl mx-auto text-center">
          <h3 className="text-lg font-bold mb-1">{t('welfareHeading')}</h3>
          <p className="text-xs text-blue-200 max-w-xl mx-auto mb-6">
            {t('welfareSub')}
          </p>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 max-w-3xl mx-auto">
            <div className="p-3.5 rounded-xl bg-white/10 border border-white/10">
              <div className="text-2xl font-black text-amber-400 font-mono">
                {dbStats?.verifiedWorkers || 18}+
              </div>
              <div className="text-[11px] text-blue-200 font-bold mt-0.5">{t('statVerifiedWorkers')}</div>
            </div>

            <div className="p-3.5 rounded-xl bg-white/10 border border-white/10">
              <div className="text-2xl font-black text-white font-mono">
                {dbStats?.cooperatives || 5}
              </div>
              <div className="text-[11px] text-blue-200 font-bold mt-0.5">{t('statCooperatives')}</div>
            </div>

            <div className="p-3.5 rounded-xl bg-white/10 border border-white/10">
              <div className="text-2xl font-black text-green-400 font-mono">
                {dbStats?.completedBookings || 24}+
              </div>
              <div className="text-[11px] text-blue-200 font-bold mt-0.5">{t('statJobsCompleted')}</div>
            </div>

            <div className="p-3.5 rounded-xl bg-white/10 border border-white/10">
              <div className="text-2xl font-black text-amber-300 font-mono">
                99.4%
              </div>
              <div className="text-[11px] text-blue-200 font-bold mt-0.5">{t('statSatisfaction')}</div>
            </div>
          </div>
        </div>
      </section>

      {/* ─────────────────────────────────────────────────────────────
          8. WORKER REGISTRATION CALLOUT BANNER
         ───────────────────────────────────────────────────────────── */}
      <section className="py-10 bg-white px-4">
        <div className="max-w-4xl mx-auto p-6 sm:p-7 rounded-3xl bg-gradient-to-br from-amber-500 via-amber-600 to-orange-600 text-white shadow-lg flex flex-col md:flex-row items-center justify-between gap-5 text-left">
          <div className="space-y-1">
            <span className="inline-block px-2.5 py-0.5 rounded-full bg-white/20 text-white text-[10px] font-black uppercase tracking-wider">
              {t('workerCampaignBadge')}
            </span>
            <h3 className="text-xl sm:text-2xl font-extrabold leading-tight">
              {t('workerCampaignTitle')}
            </h3>
            <p className="text-xs text-amber-100 max-w-lg leading-relaxed">
              {t('workerCampaignDesc')}
            </p>
          </div>

          <div className="shrink-0 w-full md:w-auto">
            <Link
              to="/register?role=worker"
              className="w-full md:w-auto btn bg-blue-950 hover:bg-black text-white text-xs font-black px-6 py-3 rounded-xl shadow-md flex items-center justify-center gap-2 border border-white/20"
            >
              <span>{t('workerJoinBtn')}</span>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}


