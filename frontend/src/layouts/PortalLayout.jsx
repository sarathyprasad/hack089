import React, { useState } from 'react';
import { Outlet, Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import {
  Building2, User, LogOut, LayoutDashboard, Briefcase,
  ShieldCheck, HeartPulse, MapPin, PhoneCall, AlertTriangle,
  Menu, X, Volume2, VolumeX, Sun, Moon, ArrowRight, ShieldAlert,
  HelpCircle, ChevronRight, Home, Wrench, Search, PlusCircle,
  FileText, CheckCircle2, UserCheck, Bell, ExternalLink
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { useAccessibility } from '../context/AccessibilityContext';

export default function PortalLayout() {
  const { user, logout, isCustomer, isWorker, isAdmin } = useAuth();
  const { lang, setLang, t } = useLanguage();
  const { fontSize, setFontSize, highContrast, toggleHighContrast, isSpeaking, speakText, stopSpeaking } = useAccessibility();
  const [sidebarOpen, setSidebarOpen] = useState(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('portal_sidebar_open');
      if (saved !== null) return saved === 'true';
      return window.innerWidth >= 768;
    }
    return true;
  });
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const toggleSidebar = () => {
    setSidebarOpen((prev) => {
      const next = !prev;
      localStorage.setItem('portal_sidebar_open', String(next));
      return next;
    });
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  // Language-aware role labels and navigation items
  const getRoleConfig = () => {
    const i18n = {
      EN: {
        adminTitle: 'Federation Command Center',
        adminSub: 'Cooperative Governance & GIS Oversight',
        adminBadge: 'Cooperative Authority',
        workerTitle: 'Worker Member Terminal',
        workerSub: 'Artisan Duty & Dispatch Workspace',
        workerBadge: 'Verified Artisan',
        citizenTitle: 'Citizen Service Portal',
        citizenSub: 'Personal Bookings & Tax Invoices',
        citizenBadge: 'Verified Resident',
        
        navMyBookings: 'My Bookings',
        navBookService: 'Book a Service',
        navFindWorker: 'Find Worker',
        navHelpdesk: 'Help & Grievance',
        navGisMap: 'GIS Live Map & Dispatches',
        navWorkOrders: 'Active Work Orders',
        navWelfare: 'Social Security & Welfare',
        navWorkerHelp: 'Worker Helpline',
        
        viewPublicSite: 'View Public Website',
        helplineTitle: 'Citizen Support',
        sessionStatus: 'SSL 256-Bit Encrypted Secure Session • State Cooperative Active Node'
      },
      HI: {
        adminTitle: 'सहकारी महासंघ प्रशासन केंद्र',
        adminSub: 'सहकारी प्रबंधन एवं जीआईएस निगरानी',
        adminBadge: 'सहकारी अधिकारी',
        workerTitle: 'श्रम साथी सदस्य टर्मिनल',
        workerSub: 'कारीगर कार्य एवं आवंटन कक्ष',
        workerBadge: 'सत्यापित कारीगर',
        citizenTitle: 'नागरिक सेवा पोर्टल',
        citizenSub: 'व्यक्तिगत बुकिंग एवं टैक्स रसीद',
        citizenBadge: 'सत्यापित नागरिक',
        
        navMyBookings: 'मेरी बुकिंग्स',
        navBookService: 'सेवा बुक करें',
        navFindWorker: 'कारीगर खोजें',
        navHelpdesk: 'सहायता एवं शिकायत',
        navGisMap: 'जीआईएस लाइव मैप व आवंटन',
        navWorkOrders: 'सक्रिय कार्य आदेश',
        navWelfare: 'कल्याण कोष व सामाजिक सुरक्षा',
        navWorkerHelp: 'श्रमिक हेल्पलाइन',
        
        viewPublicSite: 'मुख्य वेबसाइट देखें',
        helplineTitle: 'नागरिक सहायता',
        sessionStatus: 'एसएसएल 256-बिट सुरक्षित सत्र • राज्य सहकारी सक्रिय नोड'
      },
      OR: {
        adminTitle: 'ସମବାୟ ମହାସଂଘ ପ୍ରଶାସନ କେନ୍ଦ୍ର',
        adminSub: 'ସମବାୟ ପ୍ରଶାସନ ଓ ଜିଆଇଏସ୍ ନିରୀକ୍ଷଣ',
        adminBadge: 'ସମବାୟ ଅଧିକାରୀ',
        workerTitle: 'ଶ୍ରମ ସାଥୀ ସଦସ୍ୟ ଟର୍ମିନାଲ୍',
        workerSub: 'ଶ୍ରମିକ କାର୍ଯ୍ୟ ଓ ବଣ୍ଟନ କକ୍ଷ',
        workerBadge: 'ପ୍ରମାଣିତ କାରିଗର',
        citizenTitle: 'ନାଗରିକ ସେବା ପୋର୍ଟାଲ',
        citizenSub: 'ବ୍ୟକ୍ତିଗତ ବୁକିଂ ଓ ଟିକସ ବିଲ୍',
        citizenBadge: 'ପ୍ରମାଣିତ ନାଗରିକ',
        
        navMyBookings: 'ମୋ ବୁକିଂ',
        navBookService: 'ସେବା ବୁକ୍ କରନ୍ତୁ',
        navFindWorker: 'ଶ୍ରମିକ ଖୋଜନ୍ତୁ',
        navHelpdesk: 'ସହାୟତା ଓ ଅଭିଯୋଗ',
        navGisMap: 'ଜିଆଇଏସ୍ ଲାଇଭ୍ ମ୍ୟାପ୍',
        navWorkOrders: 'ସକ୍ରିୟ କାର୍ଯ୍ୟ ଅର୍ଡର',
        navWelfare: 'କଲ୍ୟାଣ ପାଣ୍ଠି ଓ ସୁରକ୍ଷା',
        navWorkerHelp: 'ଶ୍ରମିକ ହେଲ୍ପଲାଇନ୍',
        
        viewPublicSite: 'ମୂଳ ୱେବସାଇଟ୍ ଦେଖନ୍ତୁ',
        helplineTitle: 'ନାଗରିକ ସହାୟତା',
        sessionStatus: 'ଏସଏସଏଲ ୨୫୬-ବିଟ୍ ସୁରକ୍ଷିତ ସତ୍ର • ରାଜ୍ୟ ସମବାୟ ସକ୍ରିୟ ନୋଡ୍'
      },
      BN: {
        adminTitle: 'সমবায় ফেডারেশন প্রশাসন',
        adminSub: 'প্রশাসন ও জিআইএস পর্যবেক্ষণ',
        adminBadge: 'সমবায় কর্মকর্তা',
        workerTitle: 'শ্রমিক সদস্য টার্মিনাল',
        workerSub: 'কর্মী কার্যক্ষেত্র ও বরাদ্দ',
        workerBadge: 'যাচাইকৃত কারিগর',
        citizenTitle: 'নাগরিক সেবা পোর্টাল',
        citizenSub: 'ব্যক্তিগত বুকিং ও ট্যাক্স চালান',
        citizenBadge: 'যাচাইকৃত নাগরিক',
        
        navMyBookings: 'আমার বুকিং',
        navBookService: 'সেবা বুক করুন',
        navFindWorker: 'কর্মী খুঁজুন',
        navHelpdesk: 'সহায়তা ও অভিযোগ',
        navGisMap: 'জিআইএস লাইভ ম্যাপ',
        navWorkOrders: 'সক্রিয় কাজের আদেশ',
        navWelfare: 'কল্যাণ তহবিল ও সামাজিক সুরক্ষা',
        navWorkerHelp: 'কর্মী হেল্পলাইন',
        
        viewPublicSite: 'মূল ওয়েবসাইট দেখুন',
        helplineTitle: 'নাগরিক সহায়তা',
        sessionStatus: 'এসএসএল ২৫৬-বিট নিরাপদ সেশন • রাজ্য সমবায় সক্রিয় নোড'
      },
      TE: {
        adminTitle: 'సహకార సమాఖ్య పరిపాలన కేంద్రం',
        adminSub: 'పరిపాలన మరియు జీఐఎస్ పర్యవేక్షణ',
        adminBadge: 'సహకార అధికారి',
        workerTitle: 'కార్మిక సభ్యుల టెర్మినల్',
        workerSub: 'కార్మికుల కేటాయింపు కార్యస్థలం',
        workerBadge: 'ధృవీకరించబడిన కార్మికుడు',
        citizenTitle: 'పౌర సేవా పోర్టల్',
        citizenSub: 'వ్యక్తిగత బుకింగ్‌లు & పన్ను రసీదులు',
        citizenBadge: 'ధృవీకరించబడిన పౌరుడు',
        
        navMyBookings: 'నా బుకింగ్‌లు',
        navBookService: 'సేవను బుక్ చేయండి',
        navFindWorker: 'కార్మికుడిని కనుగొనండి',
        navHelpdesk: 'సహాయం & ఫిర్యాదులు',
        navGisMap: 'జీఐఎస్ ప్రత్యక్ష మ్యాప్',
        navWorkOrders: 'సక్రియ పని ఆర్డర్లు',
        navWelfare: 'సంక్షేమ నిధి & సామాజిక భద్రత',
        navWorkerHelp: 'కార్మిక హెల్ప్‌లైన్',
        
        viewPublicSite: 'ప్రజా వెబ్‌సైట్‌ను చూడండి',
        helplineTitle: 'పౌర సహాయం',
        sessionStatus: 'SSL 256-బిట్ సురక్షిత సెషన్ • రాష్ట్ర సహకార సక్రియ నోడ్'
      }
    };

    const dict = i18n[lang] || i18n.EN;

    if (isAdmin) {
      return {
        title: dict.adminTitle,
        sub: dict.adminSub,
        badge: dict.adminBadge,
        badgeClass: 'bg-amber-100 text-amber-900 border-amber-300',
        dict,
        navItems: [
          { to: '/admin/dashboard', label: dict.navGisMap, icon: LayoutDashboard, end: true },
          { to: '/find-worker', label: dict.navFindWorker, icon: Search },
          { to: '/help', label: dict.navHelpdesk, icon: HelpCircle },
        ],
      };
    }
    if (isWorker) {
      return {
        title: dict.workerTitle,
        sub: dict.workerSub,
        badge: dict.workerBadge,
        badgeClass: 'bg-green-100 text-green-900 border-green-300',
        dict,
        navItems: [
          { to: '/worker/dashboard', label: dict.navWorkOrders, icon: Briefcase, end: true },
          { to: '/worker/welfare', label: dict.navWelfare, icon: HeartPulse },
          { to: '/help', label: dict.navWorkerHelp, icon: HelpCircle },
        ],
      };
    }
    // Citizen / Customer
    return {
      title: dict.citizenTitle,
      sub: dict.citizenSub,
      badge: dict.citizenBadge,
      badgeClass: 'bg-blue-100 text-blue-900 border-blue-300',
      dict,
      navItems: [
        { to: '/customer/bookings', label: dict.navMyBookings, icon: FileText, end: false },
        { to: '/book-service', label: dict.navBookService, icon: PlusCircle },
        { to: '/find-worker', label: dict.navFindWorker, icon: Search },
        { to: '/help', label: dict.navHelpdesk, icon: HelpCircle },
      ],
    };
  };

  const roleConfig = getRoleConfig();
  const dict = roleConfig.dict;

  const handleVoiceListen = () => {
    if (isSpeaking) {
      stopSpeaking();
      return;
    }
    const currentLangText = {
      EN: `You are in your ${roleConfig.sub}. Welcome ${user?.name || ''}. Here you can manage your orders, track status, view invoices, or trigger emergency support.`,
      HI: `आप अपने ${roleConfig.title} में हैं। स्वागत है ${user?.name || ''}। यहाँ आप अपने ऑर्डर देख सकते हैं, स्थिति ट्रैक कर सकते हैं, या आपातकालीन सहायता प्राप्त कर सकते हैं।`,
      OR: `ଆପଣ ନିଜର ${roleConfig.title}ରେ ଅଛନ୍ତି। ସ୍ୱାଗତ ${user?.name || ''}। ଏଠାରେ ଆପଣ ଅର୍ଡର ଦେଖିପାରିବେ ଏବଂ ସହାୟତା ପାଇପାରିବେ।`,
      BN: `আপনি আপনার ${roleConfig.title}ে আছেন। স্বাগতম ${user?.name || ''}।`,
      TE: `మీరు మీ ${roleConfig.title} లో ఉన్నారు. స్వాగతం ${user?.name || ''}.`
    };
    speakText(currentLangText[lang] || currentLangText.EN);
  };

  return (
    <div className="portal-layout">
      {/* ── Top Tricolor Line ── */}
      <div className="tricolor-ribbon" />

      {/* ── Dedicated Logged-In Top Bar ── */}
      <header className="portal-topbar">
        {/* Left: 3-Line Hamburger Menu Button & Role Title */}
        <div className="flex items-center gap-2.5">
          <button
            type="button"
            onClick={toggleSidebar}
            className="p-2 rounded-lg text-white bg-white/10 hover:bg-white/20 transition flex items-center justify-center cursor-pointer shadow-xs"
            title={sidebarOpen ? "Close sidebar (3-line menu)" : "Open sidebar (3-line menu)"}
            aria-label="Toggle Navigation Sidebar"
          >
            {sidebarOpen ? <X size={20} className="text-amber-300" /> : <Menu size={20} className="text-white" />}
          </button>

          <Link to="/" className="flex items-center gap-2.5 text-white" title={t('brandName')}>
            <img
              src="/logo.png"
              alt="Shram Setu Logo"
              className="w-9 h-9 object-contain rounded-lg bg-white p-0.5 shadow-sm shrink-0"
            />
            <div>
              <div className="text-sm font-extrabold tracking-tight flex items-center gap-2">
                <span>{roleConfig.title}</span>
                <span className="hidden sm:inline-block text-[10px] font-bold px-2 py-0.2 rounded-full bg-amber-400/20 text-amber-300 border border-amber-400/40">
                  {roleConfig.sub}
                </span>
              </div>
              <div className="text-[10px] text-blue-200">
                {t('brandName')} • {t('brandSubtitle')}
              </div>
            </div>
          </Link>
        </div>

        {/* Right: Accessibility Controls & User Profile */}
        <div className="flex items-center gap-3">
          {/* Quick Voice Reader */}
          <button
            onClick={handleVoiceListen}
            className={`hidden sm:inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-xs font-semibold transition ${
              isSpeaking
                ? 'bg-amber-400 text-blue-950 font-bold animate-pulse'
                : 'bg-white/10 text-white hover:bg-white/20'
            }`}
            title={t('listenVoice')}
          >
            {isSpeaking ? <VolumeX size={14} className="text-red-700" /> : <Volume2 size={14} />}
            <span>{isSpeaking ? t('stopVoice') : t('listenVoice')}</span>
          </button>

          {/* Indic Language Switcher */}
          <div className="hidden lg:flex items-center gap-1 bg-black/20 p-0.5 rounded text-[11px] font-bold">
            <button
              onClick={() => setLang('EN')}
              className={`px-1.5 py-0.5 rounded transition ${lang === 'EN' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-300 hover:text-white'}`}
            >
              English
            </button>
            <button
              onClick={() => setLang('HI')}
              className={`px-1.5 py-0.5 rounded transition ${lang === 'HI' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-300 hover:text-white'}`}
            >
              हिंदी
            </button>
            <button
              onClick={() => setLang('OR')}
              className={`px-1.5 py-0.5 rounded transition ${lang === 'OR' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-300 hover:text-white'}`}
            >
              ଓଡ଼ିଆ
            </button>
            <button
              onClick={() => setLang('BN')}
              className={`px-1.5 py-0.5 rounded transition ${lang === 'BN' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-300 hover:text-white'}`}
            >
              বাংলা
            </button>
            <button
              onClick={() => setLang('TE')}
              className={`px-1.5 py-0.5 rounded transition ${lang === 'TE' ? 'bg-amber-400 text-blue-950 font-extrabold' : 'text-gray-300 hover:text-white'}`}
            >
              తెలుగు
            </button>
          </div>

          {/* User Profile Pill */}
          <div className="relative">
            <button
              onClick={() => setUserDropdownOpen(!userDropdownOpen)}
              className="flex items-center gap-2 px-2.5 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition text-left"
              aria-expanded={userDropdownOpen}
            >
              <div className="w-7 h-7 rounded-full bg-amber-400 text-blue-950 flex items-center justify-center text-xs font-black shrink-0">
                {user?.name ? user.name.charAt(0).toUpperCase() : 'U'}
              </div>
              <div className="hidden sm:block leading-tight pr-1">
                <div className="text-xs font-bold text-white max-w-[120px] truncate">{user?.name}</div>
                <div className="text-[10px] text-amber-300 font-semibold">{user?.role}</div>
              </div>
            </button>

            {/* User Dropdown Menu */}
            {userDropdownOpen && (
              <div className="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-xl border border-gray-200 py-2 z-50 text-gray-800">
                <div className="px-4 py-2 border-b border-gray-100">
                  <div className="text-xs font-bold text-gray-900">{user?.name}</div>
                  <div className="text-[11px] text-gray-500 truncate">{user?.email}</div>
                  <div className="mt-1 inline-block text-[10px] font-bold px-2 py-0.5 rounded uppercase bg-blue-50 text-blue-900 border border-blue-200">
                    {user?.role}
                  </div>
                </div>

                <div className="py-1">
                  <Link
                    to="/"
                    onClick={() => setUserDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-gray-50"
                  >
                    <ExternalLink size={14} className="text-gray-500" />
                    <span>{dict.viewPublicSite}</span>
                  </Link>

                  <Link
                    to="/help"
                    onClick={() => setUserDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-gray-50"
                  >
                    <HelpCircle size={14} className="text-gray-500" />
                    <span>{dict.navHelpdesk}</span>
                  </Link>
                </div>

                <div className="pt-1 border-t border-gray-100">
                  <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-2 px-4 py-2 text-xs font-bold text-red-700 hover:bg-red-50 text-left"
                  >
                    <LogOut size={14} />
                    <span>{t('signOutBtn')}</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* ── Main Portal Body (Sidebar + Content Workspace) ── */}
      <div className="portal-main-wrapper">
        {/* Mobile Backdrop Overlay */}
        {sidebarOpen && (
          <div
            onClick={() => setSidebarOpen(false)}
            className="fixed inset-0 bg-black/40 backdrop-blur-xs z-80 md:hidden transition-opacity"
            aria-hidden="true"
          />
        )}

        {/* Sidebar Navigation */}
        <aside
          className={`portal-sidebar ${sidebarOpen ? 'open' : 'collapsed'}`}
          aria-label="Portal Navigation"
        >
          <div>
            {/* User Quick Info in Sidebar with Close button */}
            <div className="p-3 mb-4 rounded-xl bg-gray-50 border border-gray-200 flex items-center justify-between gap-2">
              <div className="flex items-center gap-2.5 overflow-hidden">
                <div className="w-9 h-9 rounded-full bg-blue-950 text-amber-300 flex items-center justify-center text-sm font-bold shrink-0">
                  {user?.name ? user.name.charAt(0).toUpperCase() : 'U'}
                </div>
                <div className="leading-tight overflow-hidden">
                  <div className="text-xs font-bold text-gray-900 truncate">{user?.name}</div>
                  <div className="text-[10px] text-gray-500 truncate">{user?.email}</div>
                  <span className={`inline-block text-[9px] font-bold px-1.5 py-0.2 rounded border uppercase mt-0.5 ${roleConfig.badgeClass}`}>
                    {roleConfig.badge}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={toggleSidebar}
                className="p-1 rounded-md text-gray-400 hover:text-gray-700 hover:bg-gray-200 transition shrink-0"
                title="Close sidebar"
                aria-label="Close sidebar"
              >
                <X size={16} />
              </button>
            </div>

            {/* Navigation Links */}
            <nav className="space-y-1">
              {roleConfig.navItems.map((item) => {
                const Icon = item.icon;
                return (
                  <NavLink
                    key={item.to}
                    to={item.to}
                    end={item.end}
                    onClick={() => {
                      if (window.innerWidth < 768) setSidebarOpen(false);
                    }}
                    className={({ isActive }) => `portal-nav-link ${isActive ? 'active' : ''}`}
                  >
                    <Icon size={18} className="portal-nav-icon shrink-0" />
                    <span>{item.label}</span>
                  </NavLink>
                );
              })}
            </nav>
          </div>

          {/* Sidebar Footer: Helpline */}
          <div className="pt-4 border-t border-gray-200 space-y-3">
            <div className="p-3 bg-amber-50 rounded-xl border border-amber-200 text-amber-900 text-xs">
              <div className="font-bold flex items-center gap-1.5 mb-1">
                <PhoneCall size={14} className="text-amber-700" />
                <span>{dict.helplineTitle}</span>
              </div>
              <div className="text-[11px] text-amber-800">
                {t('tollFreeLabel')}: <strong className="font-mono">1800-345-7788</strong>
              </div>
            </div>

            <button
              onClick={handleLogout}
              className="w-full flex items-center justify-center gap-2 p-2 rounded-lg text-xs font-bold text-gray-600 hover:text-red-700 hover:bg-gray-100 transition"
            >
              <LogOut size={14} />
              <span>{t('signOutBtn')}</span>
            </button>
          </div>
        </aside>

        {/* Dynamic Portal Page Content */}
        <main className="portal-content">
          <Outlet />
        </main>
      </div>

      {/* ── Secure Minimal Portal Footer ── */}
      <footer className="py-3 px-6 bg-white border-t border-gray-200 text-center text-xs text-gray-500 flex flex-col sm:flex-row items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <span className="inline-block w-2 h-2 rounded-full bg-green-500"></span>
          <span>{dict.sessionStatus}</span>
        </div>
        <div className="text-[11px]">
          {t('tollFreeLabel')}: <strong>1800-345-7788</strong> | Emergency: <strong>112</strong>
        </div>
      </footer>
    </div>
  );
}
