import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../services/api';
import {
  Zap, Droplets, Hammer, Paintbrush, SprayCan, Flower2,
  HeartPulse, Car, Wrench, Home as HomeIcon, Settings, AlertTriangle,
  Search, Users, ArrowRight, ShieldCheck, CheckCircle2, Clock,
  Mic, MicOff, PhoneCall, IndianRupee, X, Snowflake, Wind
} from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';

const ICON_MAP = {
  Zap, Droplets, Hammer, Paintbrush, SprayCan, Flower2,
  HeartPulse, Car, Wrench, Home: HomeIcon, Settings, AlertTriangle,
  Snowflake, Wind
};

export default function Services() {
  const { lang, t } = useLanguage();
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();

  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || 'ALL');
  const [searchQuery, setSearchQuery] = useState(searchParams.get('search') || searchParams.get('q') || '');
  const [isListeningMic, setIsListeningMic] = useState(false);

  useEffect(() => {
    const cat = searchParams.get('category');
    const q = searchParams.get('search') || searchParams.get('q');
    if (cat) setSelectedCategory(cat);
    if (q) setSearchQuery(q);
  }, [searchParams]);

  useEffect(() => {
    api.getServices()
      .then((data) => setServices(data.services || []))
      .catch((err) => console.error('Failed to load services:', err))
      .finally(() => setLoading(false));
  }, []);

  const categories = ['ALL', ...new Set(services.map((s) => s.category))];

  const handleVoiceSearch = () => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      alert('Voice search is not supported in this browser.');
      return;
    }
    const recognition = new SpeechRecognition();
    recognition.lang = lang === 'HI' ? 'hi-IN' : lang === 'OR' ? 'or-IN' : lang === 'BN' ? 'bn-IN' : lang === 'TE' ? 'te-IN' : 'en-IN';
    recognition.interimResults = false;

    setIsListeningMic(true);
    recognition.onresult = (event) => {
      setSearchQuery(event.results[0][0].transcript);
      setIsListeningMic(false);
    };
    recognition.onerror = () => setIsListeningMic(false);
    recognition.onend = () => setIsListeningMic(false);
    recognition.start();
  };

  const filteredServices = services.filter((s) => {
    const matchesCategory = selectedCategory === 'ALL' || s.category.toLowerCase() === selectedCategory.toLowerCase();
    const q = searchQuery.toLowerCase().trim();
    if (!q) return matchesCategory;

    const matchesSearch =
      s.name.toLowerCase().includes(q) ||
      s.description.toLowerCase().includes(q) ||
      s.category.toLowerCase().includes(q);
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="container py-8 max-w-6xl mx-auto px-4">
      {/* Page Header */}
      <div className="mb-8">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 border-b border-gray-200 pb-5">
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-100 text-blue-900 text-xs font-bold uppercase tracking-wider mb-2">
              <ShieldCheck size={14} /> {t('servicesDirectoryBadge')}
            </div>
            <h1 className="text-2xl md:text-3xl font-extrabold text-gray-900">
              {t('secServices')}
            </h1>
            <p className="text-xs sm:text-sm text-gray-600 mt-1">
              {t('secServicesSub')}
            </p>
          </div>

          <Link to="/book-service" className="btn btn-saffron font-bold text-xs shadow-sm self-start md:self-auto flex items-center gap-2">
            <span>{t('btnBookNow')}</span> <ArrowRight size={15} />
          </Link>
        </div>
      </div>

      {/* Regulated Tariff Guarantee & Rate Card Banner */}
      <div className="mb-6 p-4 rounded-2xl bg-gradient-to-r from-emerald-950 via-slate-900 to-blue-950 text-white flex flex-col sm:flex-row items-center justify-between gap-3 text-xs shadow-sm">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center justify-center font-bold shrink-0">
            <ShieldCheck size={20} />
          </div>
          <div>
            <div className="font-extrabold text-white flex items-center gap-2">
              <span>93-2-5 Cooperative Tariff & Shram Suraksha Cover</span>
              <span className="text-[10px] bg-emerald-500/20 text-emerald-300 px-2 py-0.2 rounded-full border border-emerald-500/30 font-bold">Zero Surge</span>
            </div>
            <p className="text-[11px] text-slate-300 mt-0.5">
              Fixed regulated tariffs with capped labour fees (₹199–₹349 vs commercial ₹499). Backed by 30-Day Free Workmanship Warranty.
            </p>
          </div>
        </div>
        <Link
          to="/rate-card"
          className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs px-4 py-2 rounded-xl transition shrink-0 flex items-center gap-1.5 shadow-xs"
        >
          <span>View Rate Card →</span>
        </Link>
      </div>

      {/* Search & Filter Bar */}
      <div className="bg-white p-4 rounded-2xl border border-gray-200 shadow-xs mb-8 space-y-3">
        <div className="flex flex-col md:flex-row gap-3">
          <div className="relative flex-1">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-gray-400">
              <Search size={18} />
            </div>
            <input
              type="text"
              placeholder={t('searchServicesPlaceholder')}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-12 py-2.5 border border-gray-300 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-blue-900"
            />
            <button
              type="button"
              onClick={handleVoiceSearch}
              className={`absolute inset-y-0 right-0 pr-3 flex items-center transition ${
                isListeningMic ? 'text-red-600 animate-pulse' : 'text-gray-400 hover:text-blue-900'
              }`}
              title={t('voiceSearchTitle')}
            >
              {isListeningMic ? <MicOff size={18} /> : <Mic size={18} />}
            </button>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 text-xs">
          <span className="text-gray-500 font-bold uppercase tracking-wider shrink-0 mr-1 text-[10px]">
            {t('categoryLabel')}:
          </span>
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-full whitespace-nowrap font-bold transition text-xs ${
                selectedCategory === cat
                  ? 'bg-blue-950 text-white shadow-xs'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
               {cat === 'ALL' ? t('allCategories') : cat}
            </button>
          ))}
        </div>
      </div>

      {/* Services Grid */}
      {loading ? (
        <div className="text-center py-16">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
          <p className="text-sm text-gray-600">{t('loadingServices')}</p>
        </div>
      ) : filteredServices.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-2xl border border-gray-200">
          <p className="text-gray-600 font-medium">{t('noServicesFound')}</p>
          <button
            onClick={() => { setSelectedCategory('ALL'); setSearchQuery(''); }}
            className="mt-3 text-xs text-blue-900 font-bold underline"
          >
            {t('clearFilters')}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredServices.map((service) => {
            const IconComponent = ICON_MAP[service.icon] || Settings;
            const isEmergency = service.category === 'Emergency Services';

            return (
              <div
                key={service.id}
                className={`bg-white rounded-2xl border transition flex flex-col justify-between overflow-hidden shadow-xs hover:shadow-md ${
                  isEmergency
                    ? 'border-red-300 ring-1 ring-red-200'
                    : 'border-gray-200 hover:border-amber-400'
                }`}
              >
                {isEmergency && (
                  <div className="bg-red-600 text-white text-[10px] font-bold px-3 py-1 flex items-center justify-between uppercase tracking-wider">
                    <span>⚡ {t('priorityEmergency')}</span>
                    <span className="bg-white/20 px-1.5 rounded">{t('responseTime')}</span>
                  </div>
                )}

                <div className="p-5">
                  <div className="flex items-start justify-between gap-3 mb-3">
                    <div
                      className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${
                        isEmergency
                          ? 'bg-red-100 text-red-700'
                          : 'bg-blue-950 text-amber-300'
                      }`}
                    >
                      <IconComponent size={24} />
                    </div>

                    <span className="text-[11px] font-bold px-2 py-0.5 rounded bg-gray-100 text-gray-700">
                      {service.category}
                    </span>
                  </div>

                  <h3 className="font-bold text-gray-900 text-base mb-1">
                    {service.name}
                  </h3>
                  <p className="text-xs text-gray-600 line-clamp-2 mb-4 leading-relaxed">
                    {service.description}
                  </p>

                  <div className="flex items-center justify-between text-xs py-2 border-t border-gray-100">
                    <div className="flex items-center gap-1.5 text-gray-600">
                      <Users size={14} className="text-green-700" />
                      <span><strong>{service.available_workers}</strong> {t('verifiedWorkerCount')}</span>
                    </div>

                    <div className="text-right">
                      <span className="text-[10px] text-gray-500 block uppercase font-bold">{t('coopBaseRate')}</span>
                      <span className="text-base font-extrabold text-blue-950 font-mono">
                        ₹{service.base_price}
                      </span>
                      <span className="text-[10px] text-gray-500 font-normal ml-0.5">
                        /{service.price_unit?.replace('_', ' ')}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="p-3.5 bg-gray-50 border-t border-gray-100 flex items-center justify-between gap-2">
                  <Link
                    to={`/services/${service.id}`}
                    className="text-xs text-slate-700 hover:text-blue-900 font-bold flex items-center gap-1 hover:underline"
                  >
                    <span>View Process</span>
                    <ArrowRight size={12} />
                  </Link>

                  <div className="flex items-center gap-2">
                    <Link
                      to={`/find-worker?skill=${encodeURIComponent(service.category)}`}
                      className="text-xs text-gray-500 hover:text-gray-800 font-medium hidden sm:inline"
                    >
                      Artisans
                    </Link>

                    <button
                      onClick={() => navigate(`/book-service?serviceId=${service.id}`)}
                      className={`btn btn-sm text-xs font-bold ${
                        isEmergency ? 'bg-red-600 hover:bg-red-700 text-white' : 'btn-primary'
                      }`}
                    >
                      {t('bookBtn')}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
