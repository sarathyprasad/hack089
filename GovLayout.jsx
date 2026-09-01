import React, { useState } from 'react';
import { Outlet, Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import {
  Menu, X, Building2, User, LogOut, LayoutDashboard,
  ShieldCheck, PhoneCall, Volume2, VolumeX, Sun, Moon,
  Landmark, Sparkles, ChevronRight, HelpCircle, ExternalLink
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { useAccessibility } from '../context/AccessibilityContext';

export default function GovLayout() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { user, logout, isAuthenticated, isCustomer, isWorker, isAdmin } = useAuth();
  const { lang, setLang, t } = useLanguage();
  const { fontSize, setFontSize, highContrast, toggleHighContrast, isSpeaking, speakText, stopSpeaking } = useAccessibility();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/');
    setMobileMenuOpen(false);
  };

  const getDashboardRoute = () => {
    if (isAdmin) return '/admin/dashboard';
    if (isWorker) return '/worker/dashboard';
    return '/customer/bookings';
  };

  const getRoleBadge = () => {
    if (isAdmin) {
      const labels = { EN: 'Admin', HI: 'प्रशासक', OR: 'ପ୍ରଶାସକ', BN: 'প্রশাসক', TE: 'అడ్మిన్' };
      return { label: labels[lang] || 'Admin', style: 'bg-amber-100 text-amber-900 border-amber-300' };
    }
    if (isWorker) {
      const labels = { EN: 'Artisan / Worker', HI: 'कुशल कारीगर', OR: 'କୁଶଳୀ ଶ୍ରମିକ', BN: 'দক্ষ কারিগর', TE: 'నైపుణ్యం కలిగిన కార్మికుడు' };
      return { label: labels[lang] || 'Worker', style: 'bg-green-100 text-green-900 border-green-300' };
    }
    const labels = { EN: 'Citizen', HI: 'नागरिक', OR: 'ନାଗରିକ', BN: 'নাগরিক', TE: 'పౌరుడు' };
    return { label: labels[lang] || 'Citizen', style: 'bg-blue-100 text-blue-900 border-blue-300' };
  };

  const handleVoiceListen = () => {
    if (isSpeaking) {
      stopSpeaking();
      return;
    }
    const currentLangText = {
      EN: "Welcome to Sahakari SevaSetu, the official Government Cooperative Labour Services Portal. Verified skills, fair wages, zero surge pricing, and direct social security for all artisans. You can book an electrical, plumbing, carpentry or appliance service directly online or dial toll free 1800-345-7788.",
      HI: "सहकारी सेवासेतु में आपका स्वागत है। यह सरकारी श्रम सहकारी सेवा पोर्टल है। प्रमाणित कारीगर, उचित सरकारी दरें, शून्य अतिरिक्त शुल्क और 100% सामाजिक सुरक्षा। आप ऑनलाइन सेवा बुक कर सकते हैं या टोल-फ्री 1800-345-7788 पर कॉल करें।",
      OR: "ସହକାରୀ ସେବାସେତୁ ପୋର୍ଟାଲକୁ ସ୍ୱାଗତ। ଏହା ସରକାରୀ ଶ୍ରମ ସମବାୟ ମହାସଂଘର ଏକ ପ୍ରୟାସ। ପ୍ରମାଣିତ ଶ୍ରମିକ, ସରକାରୀ ଦର ଏବଂ ସାମାଜିକ ସୁରକ୍ଷା। ସେବା ବୁକ୍ କରିବା ପାଇଁ ଟୋଲ୍ ଫ୍ରି ୧୮୦୦-୩୪୫-୭୭୮୮ ଡାଏଲ କରନ୍ତୁ।",
      BN: "সহকারী সেবা সেতুতে স্বাগতম। এটি সরকারি সমবায় শ্রম সেবা পোর্টাল। যাচাইকৃত কর্মী, ন্যায্য সরকারি মূল্য এবং সামাজিক সুরক্ষা। সেবা বুক করতে ১৮০০-৩৪৫-৭৭৮৮ নম্বরে কল করুন।",
      TE: "సహకారి సేవాసేతుకు స్వాగతం. ఇది ప్రభుత్వ సహకార కార్మిక సేవల పోర్టల్. ధృవీకరించబడిన నైపుణ్యాలు మరియు సామాజిక భద్రత. సేవను బుక్ చేయడానికి టోల్ ఫ్రీ 1800-345-7788 కు కాల్ చేయండి."
    };
    speakText(currentLangText[lang] || currentLangText.EN);
  };

  const navLinks = [
    { to: '/', label: t('navHome') },
    { to: '/services', label: t('navServices') },
    { to: '/find-worker', label: t('navFindWorker') },
    { to: '/book-service', label: t('navBookService') },
    { to: '/about', label: t('navAbout') },
    { to: '/help', label: t('navHelp') },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-[#F8FAFC]">
      {/* ── 1. National Tricolor Ribbon ── */}
      <div className="tricolor-ribbon" />

      {/* ── 2. Top Accessibility & Multi-Lingual Public Bar ── */}
      <div className="gov-top-bar py-1.5 px-3 md:px-6">
        <div className="max-w-7xl mx-auto flex items-center justify-between flex-wrap gap-2 text-xs">
          {/* Left: Official Government Statement */}
          <div className="flex items-center gap-2 font-medium">
            <span className="inline-flex items-center gap-1.5 text-amber-300 font-bold">
              <Landmark size={14} className="text-amber-400 shrink-0" />
              <span>🇮🇳 {t('govSupportTag')}</span>
            </span>
          </div>

          {/* Right: Accessibility Controls & Language Switcher */}
          <div className="flex items-center gap-2.5 flex-wrap">
            {/* Toll-Free Quick Hotline */}
            <a
              href="tel:18003457788"
              className="hidden lg:inline-flex items-center gap-1 text-[11px] text-green-300 hover:text-green-200 font-bold bg-green-950/40 px-2 py-0.5 rounded border border-green-700/40"
              title="Toll-Free Citizen Assistance"
            >
              <PhoneCall size={12} />
              <span>{t('tollFreeLabel')}: 1800-345-7788</span>
            </a>

            {/* Font Size Adjusters: A- / A / A+ */}
            <div className="flex items-center gap-1 bg-white/10 p-0.5 rounded border border-white/15">
              <button
                onClick={() => setFontSize('normal')}
                className={`gov-accessibility-btn ${fontSize === 'normal' ? 'active' : ''}`}
                title="Standard Font Size"
                aria-label="Standard Font"
              >
                A
              </button>
              <button
                onClick={() => setFontSize('large')}
                className={`gov-accessibility-btn ${fontSize === 'large' ? 'active' : ''}`}
                title="Large Font Size"
                aria-label="Large Font"
              >
                A+
              </button>
              <button
                onClick={() => setFontSize('xlarge')}
                className={`gov-accessibility-btn ${fontSize === 'xlarge' ? 'active' : ''}`}
                title="Extra Large Font Size"
                aria-label="Extra Large Font"
              >
                A++
              </button>
            </div>

            {/* High Contrast Toggle */}
            <button
              onClick={toggleHighContrast}
              className={`gov-accessibility-btn ${highContrast ? 'active' : ''}`}
              title="Toggle High Contrast"
              aria-label="High Contrast Mode"
            >
              {highContrast ? <Sun size={12} /> : <Moon size={12} />}
              <span className="hidden sm:inline">{t('contrastBtn')}</span>
            </button>

            {/* Audio Voice Assistant Button */}
            <button
              onClick={handleVoiceListen}
              className={`gov-accessibility-btn ${isSpeaking ? 'bg-amber-400 text-blue-950 font-bold animate-pulse' : ''}`}
              title={t('listenVoice')}
              aria-label="Read page aloud"
            >
              {isSpeaking ? <VolumeX size={13} className="text-red-700" /> : <Volume2 size={13} />}
              <span>{isSpeaking ? t('stopVoice') : t('listenVoice')}</span>
            </button>

            {/* Indic Language Switcher */}
            <div className="flex items-center gap-1 pl-1 border-l border-white/20 text-[11px] font-bold">
              <button
                onClick={() => setLang('EN')}
                className={`px-1.5 py-0.5 rounded transition ${lang === 'EN' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-200 hover:text-white'}`}
              >
                English
              </button>
              <button
                onClick={() => setLang('HI')}
                className={`px-1.5 py-0.5 rounded transition ${lang === 'HI' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-200 hover:text-white'}`}
              >
                हिंदी
              </button>
              <button
                onClick={() => setLang('OR')}
                className={`px-1.5 py-0.5 rounded transition ${lang === 'OR' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-200 hover:text-white'}`}
              >
                ଓଡ଼ିଆ
              </button>
              <button
                onClick={() => setLang('BN')}
                className={`px-1.5 py-0.5 rounded transition ${lang === 'BN' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-200 hover:text-white'}`}
              >
                বাংলা
              </button>
              <button
                onClick={() => setLang('TE')}
                className={`px-1.5 py-0.5 rounded transition ${lang === 'TE' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-200 hover:text-white'}`}
              >
                తెలుగు
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* ── 3. Official Public Navigation Header ── */}
      <header className="gov-header" role="banner">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 flex items-center justify-between h-[72px]">
          {/* Brand & Seal */}
          <Link to="/" className="gov-brand" aria-label="Homepage">
            <div className="gov-emblem-badge">
              <Building2 size={24} className="text-amber-300" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="gov-brand-title">{t('brandName')}</span>
              </div>
              <div className="gov-brand-subtitle">
                {t('brandSubtitle')}
              </div>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center gap-1" aria-label="Public Navigation">
            {navLinks.map(({ to, label }) => (
              <NavLink
                key={to}
                to={to}
                end={to === '/'}
                className={({ isActive }) => `gov-nav-item ${isActive ? 'active' : ''}`}
              >
                {label}
              </NavLink>
            ))}
          </nav>

          {/* Auth Action Buttons */}
          <div className="hidden sm:flex items-center gap-3">
            {isAuthenticated ? (
              <div className="flex items-center gap-2.5">
                <div className="text-right hidden md:block leading-tight">
                  <div className="text-xs font-bold text-gray-800">{user?.name}</div>
                  <span className={`inline-block text-[10px] font-semibold px-1.5 py-0.2 rounded border ${getRoleBadge().style}`}>
                    {getRoleBadge().label}
                  </span>
                </div>

                <Link
                  to={getDashboardRoute()}
                  className="btn btn-primary btn-sm flex items-center gap-1.5 shadow-sm text-xs font-bold"
                >
                  <LayoutDashboard size={15} />
                  <span>{t('dashboardBtn')}</span>
                </Link>

                <button
                  onClick={handleLogout}
                  className="p-2 text-gray-500 hover:text-red-700 hover:bg-gray-100 rounded-lg transition"
                  title={t('signOutBtn')}
                  aria-label={t('signOutBtn')}
                >
                  <LogOut size={16} />
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <Link
                  to="/login"
                  className="btn btn-secondary btn-sm font-semibold text-xs border-blue-900 text-blue-950 hover:bg-blue-50"
                >
                  {t('loginBtn')}
                </Link>
                <Link
                  to="/register"
                  className="btn btn-saffron btn-sm font-bold text-xs shadow-sm"
                >
                  {t('registerBtn')}
                </Link>
              </div>
            )}
          </div>

          {/* Mobile Menu Toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="lg:hidden p-2 text-blue-950 rounded-lg hover:bg-gray-100"
            aria-expanded={mobileMenuOpen}
            aria-label="Toggle menu"
          >
            {mobileMenuOpen ? <X size={26} /> : <Menu size={26} />}
          </button>
        </div>

        {/* Mobile Dropdown Menu */}
        {mobileMenuOpen && (
          <div className="lg:hidden border-t border-gray-200 bg-white px-4 pt-3 pb-6 space-y-3 shadow-lg">
            <nav className="flex flex-col space-y-1">
              {navLinks.map(({ to, label }) => (
                <NavLink
                  key={to}
                  to={to}
                  end={to === '/'}
                  onClick={() => setMobileMenuOpen(false)}
                  className={({ isActive }) => `px-3 py-2 rounded-lg text-sm font-semibold ${isActive ? 'bg-amber-100 text-blue-950 font-bold' : 'text-gray-700 hover:bg-gray-50'}`}
                >
                  {label}
                </NavLink>
              ))}
            </nav>

            <div className="pt-3 border-t border-gray-100 flex flex-col gap-2">
              {isAuthenticated ? (
                <>
                  <div className="px-3 py-2 bg-gray-50 rounded-lg text-xs font-semibold text-gray-700">
                    Signed in as: <strong className="text-blue-950">{user?.name}</strong> ({user?.role})
                  </div>
                  <Link
                    to={getDashboardRoute()}
                    onClick={() => setMobileMenuOpen(false)}
                    className="btn btn-primary w-full text-xs font-bold"
                  >
                    <LayoutDashboard size={16} /> {t('dashboardBtn')}
                  </Link>
                  <button
                    onClick={handleLogout}
                    className="btn btn-secondary w-full text-xs text-red-700"
                  >
                    <LogOut size={16} /> {t('signOutBtn')}
                  </button>
                </>
              ) : (
                <div className="grid grid-cols-2 gap-2">
                  <Link
                    to="/login"
                    onClick={() => setMobileMenuOpen(false)}
                    className="btn btn-secondary text-xs font-bold text-center"
                  >
                    {t('loginBtn')}
                  </Link>
                  <Link
                    to="/register"
                    onClick={() => setMobileMenuOpen(false)}
                    className="btn btn-saffron text-xs font-bold text-center"
                  >
                    {t('registerBtn')}
                  </Link>
                </div>
              )}
            </div>
          </div>
        )}
      </header>

      {/* ── 4. Main Public Content ── */}
      <main className="flex-1">
        <Outlet />
      </main>

      {/* ── 5. Official Civic & Cooperative Footer ── */}
      <footer className="gov-footer" role="contentinfo">
        <div className="gov-footer-inner">
          <div className="gov-footer-grid">
            {/* Column 1: Public Cooperative Federation */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <div className="w-8 h-8 rounded bg-amber-400 text-blue-950 flex items-center justify-center font-bold">
                  <Building2 size={18} />
                </div>
                <div>
                  <div className="font-extrabold text-sm text-white">{t('brandName')}</div>
                  <div className="text-[10px] text-amber-300 uppercase font-semibold">{t('portalSubHeader')}</div>
                </div>
              </div>
              <p className="text-xs text-blue-100/80 leading-relaxed mb-4">
                {t('heroSubtitle')}
              </p>
              <div className="flex items-center gap-2 text-xs text-green-300 font-bold bg-white/5 p-2 rounded-lg border border-white/10">
                <ShieldCheck size={16} className="text-green-400 shrink-0" />
                <span>100% ITI / NSDC Certified Trades</span>
              </div>
            </div>

            {/* Column 2: Citizen Public Services */}
            <div>
              <h4>{t('navServices')}</h4>
              <ul>
                <li><Link to="/services">{t('secServices')}</Link></li>
                <li><Link to="/book-service">{t('btnBookNow')}</Link></li>
                <li><Link to="/find-worker">{t('navFindWorker')}</Link></li>
                <li><Link to="/help">{t('callBookingTitle')}</Link></li>
              </ul>
            </div>

            {/* Column 3: Artisan & Cooperative Welfare */}
            <div>
              <h4>{t('statVerifiedWorkers')}</h4>
              <ul>
                <li><Link to="/register?role=worker">{t('workerJoinBtn')}</Link></li>
                <li><Link to="/login?role=worker">{t('loginBtn')}</Link></li>
                <li><Link to="/about">{t('welfareHeading')}</Link></li>
                <li><Link to="/help">{t('navHelp')}</Link></li>
              </ul>
            </div>

            {/* Column 4: Helplines & Grievance */}
            <div>
              <h4>{t('tollFreeLabel')}</h4>
              <div className="space-y-2 text-xs text-blue-100">
                <div className="p-3 bg-white/10 rounded-xl border border-white/15">
                  <div className="text-[11px] text-amber-300 font-bold uppercase">{t('tollFreeLabel')}</div>
                  <div className="text-base font-bold text-white font-mono">1800-345-7788</div>
                  <div className="text-[10px] text-gray-300">24x7 Support</div>
                </div>
                <div className="text-[11px] text-gray-300 pt-1">
                  National Emergency: <strong>112</strong> | Ambulance: <strong>108</strong>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Bar with Statutory Disclaimers */}
          <div className="gov-footer-bottom">
            <div>
              © 2026 <strong>{t('brandName')}</strong> — {t('brandSubtitle')}. All Rights Reserved.
            </div>
            <div className="flex items-center gap-4 text-xs">
              <Link to="/about" className="hover:text-white">Form IV GST Compliant</Link>
              <span>•</span>
              <Link to="/about" className="hover:text-white">Privacy Policy</Link>
              <span>•</span>
              <Link to="/help" className="hover:text-white">Accessibility</Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
