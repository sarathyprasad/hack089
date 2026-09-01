import React, { useState, useEffect, useMemo } from 'react';
import { useSearchParams, useNavigate, Link } from 'react-router-dom';
import { api } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import {
  ShieldCheck, AlertTriangle, CheckCircle2, Star, MapPin,
  Calendar, Clock, User, ArrowRight, ArrowLeft, Zap, Check,
  Info, Sparkles, Building2, HelpCircle, Layers, ShieldAlert, Award,
  Search, X, Wrench, Droplets, Hammer, Paintbrush, SprayCan,
  LogIn, CheckSquare, Square
} from 'lucide-react';

export default function BookService() {
  const { t } = useLanguage();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { user, isAuthenticated, login } = useAuth();

  // Wizard Step: 1 = Problem Search & Service, 2 = Location & Timing, 3 = Worker Matching & Master Pairing, 4 = Review, 5 = Success
  const [currentStep, setCurrentStep] = useState(1);

  // Data states
  const [services, setServices] = useState([]);
  const [selectedService, setSelectedService] = useState(null);
  const [recommendedWorkers, setRecommendedWorkers] = useState([]);
  const [selectedWorker, setSelectedWorker] = useState(null);
  const [autoAssign, setAutoAssign] = useState(true);

  // Phase 1 Search & Problem Matching state
  const [searchQuery, setSearchQuery] = useState('');
  const [matchedDiagnosis, setMatchedDiagnosis] = useState(null);

  // Form states (Phase 2)
  const [formData, setFormData] = useState({
    district: user?.district || 'Khordha',
    city: user?.city || 'Bhubaneswar',
    address: user?.address || 'Plot 104, Patia',
    pincode: user?.pincode || '751024',
    scheduledDate: new Date().toISOString().split('T')[0],
    scheduledTime: '10:00 AM',
    isEmergency: false,
    isBulkOrder: false,
    notes: '',
  });

  const [loading, setLoading] = useState(false);
  const [matchingLoading, setMatchingLoading] = useState(false);
  const [error, setError] = useState('');
  const [createdBooking, setCreatedBooking] = useState(null);
  const [quickLoginLoading, setQuickLoginLoading] = useState(false);

  // Common Problem Presets
  const symptomPresets = [
    { label: '💧 Kitchen tap/pipe leakage', trade: 'Plumbing', service: 'Plumbing Repair', likelyParts: 'Astral 1/2" Brass Ball Valve', keywords: ['tap', 'pipe', 'leak', 'drain', 'water'] },
    { label: '⚡ Main MCB tripping repeatedly', trade: 'Electrical', service: 'Electrical Repair', likelyParts: '16A Havells Modular MCB', keywords: ['mcb', 'wire', 'fuse', 'spark', 'light'] },
    { label: '❄️ AC not cooling / low airflow', trade: 'Appliance Repair', service: 'AC/Appliance Repair', likelyParts: 'Universal AC Run Capacitor (45uF)', keywords: ['ac', 'cool', 'gas', 'fridge', 'filter'] },
    { label: '🎨 Society lobby repainting (Bulk)', trade: 'Painting', service: 'Painting Service', isBulk: true, likelyParts: 'Asian Paints Damp-Proof Acrylic Primer', keywords: ['paint', 'wall', 'coating', 'color'] },
    { label: '🚨 Emergency pipe burst (High pressure)', trade: 'Emergency Services', service: 'Emergency Plumbing', isEmergency: true, likelyParts: 'SS Flexible Waste Pipe', keywords: ['emergency', 'burst', 'urgent'] },
  ];

  // Initial load
  useEffect(() => {
    api.getServices()
      .then((data) => {
        const sList = data.services || [];
        setServices(sList);

        const queryServiceId = searchParams.get('serviceId');
        const queryCategory = searchParams.get('category');
        const querySearch = searchParams.get('search') || searchParams.get('q');
        const queryDistrict = searchParams.get('district');

        if (queryDistrict) {
          setFormData((prev) => ({ ...prev, district: queryDistrict }));
        }

        if (querySearch) {
          setSearchQuery(querySearch);
        }

        if (queryServiceId) {
          const match = sList.find((s) => s.id === parseInt(queryServiceId, 10));
          if (match) {
            setSelectedService(match);
            setMatchedDiagnosis({
              serviceName: match.name,
              trade: match.category,
              likelyParts: 'Standard Certified Toolkit',
              standardTariff: 'Govt. Regulated',
            });
            if (match.category === 'Emergency Services') {
              setFormData((prev) => ({ ...prev, isEmergency: true }));
            }
            setCurrentStep(2);
          }
        } else if (queryCategory) {
          // Normalize category query (e.g. catElectrical, Caregiving, Electrical, etc.)
          const normCat = queryCategory.toLowerCase().replace(/^cat/, '');
          const match = sList.find((s) => {
            const sc = (s.category || '').toLowerCase();
            const sn = (s.name || '').toLowerCase();
            return sc.includes(normCat) || normCat.includes(sc) || sn.includes(normCat) || normCat.includes(sn);
          }) || sList[0];

          if (match) {
            setSelectedService(match);
            setMatchedDiagnosis({
              serviceName: match.name,
              trade: match.category,
              likelyParts: 'Standard Certified Toolkit',
              standardTariff: 'Govt. Regulated',
            });
            if (match.category === 'Emergency Services') {
              setFormData((prev) => ({ ...prev, isEmergency: true }));
            }
            // Auto-advance to Step 2 so citizen can immediately configure slot & location
            setCurrentStep(2);
          }
        } else if (querySearch) {
          handleProblemMatch(querySearch);
        } else if (sList.length > 0) {
          // Default initial selection for smooth 1-click booking experience
          setSelectedService(sList[0]);
          setMatchedDiagnosis({
            serviceName: sList[0].name,
            trade: sList[0].category,
            likelyParts: 'Standard ISI Hardware Toolkit',
            standardTariff: 'Govt. Regulated',
          });
        }
      })
      .catch((err) => console.error('Failed to load services:', err));
  }, [searchParams]);

  // High-performance Multilingual & Keyword Search Filtering
  const filteredServices = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    if (!query) return services;

    return services.filter((s) => {
      const name = (s.name || '').toLowerCase();
      const cat = (s.category || '').toLowerCase();
      const desc = (s.description || '').toLowerCase();

      // Check direct text match
      if (name.includes(query) || cat.includes(query) || desc.includes(query)) return true;

      // Check common repair synonyms
      const electricalTerms = ['bijli', 'fan', 'light', 'switch', 'socket', 'plug', 'mcb', 'wire', 'wiring', 'power', 'shock', 'current', 'motor', 'spark'];
      const plumbingTerms = ['tap', 'pipe', 'leak', 'drain', 'water', 'tank', 'tanki', 'pani', 'valve', 'block', 'toilet', 'flush', 'sink', 'basin', 'plumber'];
      const applianceTerms = ['ac', 'cool', 'fridge', 'refrigerator', 'washing', 'machine', 'geyser', 'cooler', 'filter', 'purifier', 'gas'];
      const carpentryTerms = ['wood', 'door', 'lock', 'darwaza', 'handle', 'table', 'chair', 'furniture', 'bed', 'sofa', 'almirah', 'kapat'];
      const paintingTerms = ['paint', 'wall', 'color', 'putty', 'primer', 'polish', 'damp'];
      const cleaningTerms = ['clean', 'safai', 'wash', 'deep', 'dust', 'sanitize'];

      if (cat.includes('Electrical') && electricalTerms.some(t => query.includes(t))) return true;
      if (cat.includes('Plumbing') && plumbingTerms.some(t => query.includes(t))) return true;
      if (cat.includes('Appliance') && applianceTerms.some(t => query.includes(t))) return true;
      if (cat.includes('Carpentry') && carpentryTerms.some(t => query.includes(t))) return true;
      if (cat.includes('Painting') && paintingTerms.some(t => query.includes(t))) return true;
      if (cat.includes('Cleaning') && cleaningTerms.some(t => query.includes(t))) return true;

      return false;
    });
  }, [services, searchQuery]);

  // Handle Search & Problem Match
  const handleProblemMatch = (symptomText, presetObj = null) => {
    const text = (symptomText || searchQuery).toLowerCase();
    let matched = null;

    if (presetObj) {
      setSearchQuery(presetObj.label);
      matched = services.find((s) => s.name === presetObj.service || s.category === presetObj.trade);
      if (presetObj.isEmergency) setFormData(prev => ({ ...prev, isEmergency: true }));
      if (presetObj.isBulk) setFormData(prev => ({ ...prev, isBulkOrder: true }));
      setMatchedDiagnosis({
        serviceName: presetObj.service,
        trade: presetObj.trade,
        likelyParts: presetObj.likelyParts,
        standardTariff: 'Govt. Regulated',
      });
    } else if (text.includes('ac') || text.includes('cool') || text.includes('fridge') || text.includes('refrigerator')) {
      matched = services.find((s) => s.category.includes('Appliance') || s.name.includes('Appliance'));
      setMatchedDiagnosis({
        serviceName: matched?.name || 'AC/Appliance Repair',
        trade: 'Appliance Repair',
        likelyParts: '45uF Capacitor / Gas Refill Matrix',
        standardTariff: 'Govt. Regulated',
      });
    } else if (text.includes('leak') || text.includes('pipe') || text.includes('water') || text.includes('tap') || text.includes('drain') || text.includes('pani') || text.includes('tanki')) {
      matched = services.find((s) => s.category.includes('Plumbing') || s.name.includes('Plumbing'));
      setMatchedDiagnosis({
        serviceName: matched?.name || 'Plumbing Repair',
        trade: 'Plumbing',
        likelyParts: '1/2" Brass Ball Valve / CPVC Elbow Joint',
        standardTariff: 'Govt. Regulated',
      });
    } else if (text.includes('mcb') || text.includes('wire') || text.includes('power') || text.includes('light') || text.includes('shock') || text.includes('switch') || text.includes('fan') || text.includes('bijli')) {
      matched = services.find((s) => s.category.includes('Electrical') || s.name.includes('Electrical'));
      setMatchedDiagnosis({
        serviceName: matched?.name || 'Electrical Repair',
        trade: 'Electrical',
        likelyParts: '16A Modular MCB / Copper Wiring',
        standardTariff: 'Govt. Regulated',
      });
    } else if (text.includes('paint') || text.includes('wall') || text.includes('damp') || text.includes('color')) {
      matched = services.find((s) => s.category.includes('Painting') || s.name.includes('Painting'));
      setMatchedDiagnosis({
        serviceName: matched?.name || 'Painting Service',
        trade: 'Painting',
        likelyParts: 'Damp-Proof Acrylic Primer',
        standardTariff: 'Govt. Regulated',
      });
    } else {
      matched = filteredServices[0] || services[0];
      setMatchedDiagnosis({
        serviceName: matched?.name || 'Standard Cooperative Service',
        trade: matched?.category || 'General Maintenance',
        likelyParts: 'Standard ISI Hardware Toolkit',
        standardTariff: 'Govt. Regulated',
      });
    }

    if (matched) {
      setSelectedService(matched);
    }
  };

  // Trigger Smart Worker Recommendation & Master Pairing
  const fetchRecommendations = async () => {
    if (!selectedService) return;
    setMatchingLoading(true);
    setError('');
    try {
      const data = await api.recommendWorkers({
        serviceId: selectedService.id,
        district: formData.district,
        city: formData.city,
        isEmergency: formData.isEmergency,
      });

      const list = data.recommendedWorkers || [];
      setRecommendedWorkers(list);
      if (list.length > 0) {
        setSelectedWorker(list[0]);
      }
    } catch (err) {
      console.error('Matching recommendation error:', err);
      setError('Unable to calculate recommendations right now.');
    } finally {
      setMatchingLoading(false);
    }
  };

  const handleStep2Next = async (e) => {
    e.preventDefault();
    if (!formData.address) {
      setError('Please provide service location address.');
      return;
    }
    setError('');
    setCurrentStep(3);
    await fetchRecommendations();
  };

  // Quick 1-Click Login as Demo Customer if not logged in
  const handleQuickCustomerLogin = async () => {
    setQuickLoginLoading(true);
    try {
      await login('customer@demo.local', 'demo123');
      setError('');
    } catch (err) {
      setError('Failed to perform quick login: ' + err.message);
    } finally {
      setQuickLoginLoading(false);
    }
  };

  const handleConfirmBooking = async () => {
    setLoading(true);
    setError('');
    try {
      // Auto-authenticate if guest for smooth demo booking experience
      if (!isAuthenticated) {
        try {
          await login('customer@demo.local', 'demo123');
        } catch (authErr) {
          console.warn('Guest checkout auto-login fallback:', authErr);
        }
      }

      const payload = {
        service_id: selectedService.id,
        worker_id: autoAssign ? (selectedWorker?.id || null) : (selectedWorker?.id || null),
        scheduled_date: formData.scheduledDate,
        scheduled_time: formData.scheduledTime,
        address: `${formData.address}, ${formData.city}, ${formData.district} - ${formData.pincode}`,
        district: formData.district,
        is_emergency: formData.isEmergency,
        notes: formData.notes || 'Standard booking',
      };

      const res = await api.createBooking(payload);
      setCreatedBooking(res.booking);
      setCurrentStep(5);
    } catch (err) {
      console.error('Booking submission failed:', err);
      setError(err.message || 'Failed to submit booking order.');
    } finally {
      setLoading(false);
    }
  };

  // Phase 5 90-5-5 Split Calculation
  let rawBasePrice = selectedService
    ? (formData.isEmergency ? Math.max(selectedService.base_price, 499) : selectedService.base_price)
    : 0;

  const bulkDiscount = formData.isBulkOrder ? Math.round(rawBasePrice * 0.15 * 100) / 100 : 0;
  const basePrice = rawBasePrice - bulkDiscount;
  const coopFee = Math.round(basePrice * 0.05 * 100) / 100; // 5% Welfare Fund
  const platformFee = Math.round(basePrice * 0.05 * 100) / 100; // 5% Platform Infra
  const totalEstimated = Math.round((basePrice + coopFee + platformFee) * 100) / 100;

  return (
    <div className="container py-8 max-w-5xl mx-auto px-4">
      {/* Wizard Progress Bar */}
      <div className="mb-8">
        <div className="flex items-center justify-between text-xs font-bold text-gray-500 mb-2">
          <span>{t('step1Title')}</span>
          <span>{t('step2Title')}</span>
          <span>{t('step3Title')}</span>
          <span>Confirmation</span>
        </div>
        <div className="grid grid-cols-4 gap-2">
          {[1, 2, 3, 4].map((stepNum) => {
            const isDone = currentStep > stepNum;
            const isCurrent = currentStep === stepNum;
            const labels = ['1. Service', '2. Location & Schedule', '3. Artisan Pairing', '4. Confirmation'];
            const label = labels[stepNum - 1];

            return (
              <div key={stepNum} className="flex flex-col items-center">
                <div
                  className={`h-2 w-full rounded-full transition-all duration-300 ${
                    isDone
                      ? 'bg-emerald-600'
                      : isCurrent
                      ? 'bg-blue-950 ring-2 ring-blue-950/20'
                      : 'bg-gray-200'
                  }`}
                />
                <span
                  className={`text-[11px] font-semibold mt-1.5 ${
                    isCurrent ? 'text-blue-950' : isDone ? 'text-emerald-800' : 'text-gray-400'
                  }`}
                >
                  {label}
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-xl text-red-800 text-xs flex items-center justify-between gap-3 shadow-xs">
          <div className="flex items-center gap-2">
            <AlertTriangle size={18} className="shrink-0 text-red-600" />
            <span>{error}</span>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHASE 1: PROBLEM SEARCH & TARIFF MATCHER (Clean & Optimized)
         ───────────────────────────────────────────────────────────── */}
      {currentStep === 1 && (
        <div className="bg-white p-6 md:p-8 rounded-2xl border border-gray-200 shadow-xs space-y-6">
          
          {/* Smart Problem Search Console */}
          <div className="p-6 rounded-2xl bg-gradient-to-br from-[#0A1931] via-[#102A45] to-[#163B60] text-white shadow-lg border border-blue-900/50">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-7 h-7 rounded-lg bg-amber-400/20 text-amber-400 flex items-center justify-center">
                <Search className="w-4 h-4 text-amber-400" />
              </div>
              <span className="text-xs font-bold uppercase tracking-wider text-amber-400">
                {t('problemSearchTitle')}
              </span>
            </div>
            <h2 className="text-lg font-bold">{t('problemSearchSub')}</h2>
            <p className="text-xs text-blue-200 mt-0.5 mb-4">
              {t('problemSearchDesc')}
            </p>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                handleProblemMatch(searchQuery);
              }}
              className="flex gap-2 mb-4"
            >
              <div className="relative flex-1">
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => {
                    setSearchQuery(e.target.value);
                    if (e.target.value.length > 2) {
                      handleProblemMatch(e.target.value);
                    }
                  }}
                  placeholder={t('searchIssuePlaceholder')}
                  className="w-full pl-4 pr-10 py-3 rounded-xl bg-white text-gray-950 placeholder-gray-400 font-semibold text-xs border border-gray-200 shadow-inner focus:outline-none focus:ring-2 focus:ring-amber-400"
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => {
                      setSearchQuery('');
                      setMatchedDiagnosis(null);
                    }}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-700"
                  >
                    <X size={16} />
                  </button>
                )}
              </div>
              <button
                type="submit"
                className="btn btn-saffron text-xs font-bold px-5 py-3 rounded-xl shrink-0 shadow-md flex items-center gap-1.5"
              >
                <Search size={14} />
                <span>{t('btnFindServiceRate')}</span>
              </button>
            </form>

            {/* Quick symptom presets */}
            <div className="flex flex-wrap gap-2">
              {symptomPresets.map((p, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => handleProblemMatch(p.label, p)}
                  className="text-[11px] font-medium bg-white/15 hover:bg-white/25 border border-white/20 px-3 py-1.5 rounded-lg text-white transition text-left"
                >
                  {p.label}
                </button>
              ))}
            </div>

            {matchedDiagnosis && (
              <div className="mt-4 p-3.5 bg-white/15 rounded-xl border border-white/20 text-xs flex items-center justify-between flex-wrap gap-2">
                <div>
                  <span className="text-amber-400 font-bold">✓ {t('matchedService')}: </span>
                  <strong className="text-white">{matchedDiagnosis.serviceName}</strong> ({matchedDiagnosis.trade})
                  <div className="text-[11px] text-blue-200 mt-0.5">
                    {t('likelyPartsLabel')} <strong>{matchedDiagnosis.likelyParts}</strong>
                  </div>
                </div>
                <span className="text-[10px] font-bold bg-emerald-500 text-white px-2.5 py-1 rounded-full">
                  ✓ {t('govStandardRate')}
                </span>
              </div>
            )}
          </div>

          {/* Filtered Services Grid */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-sm font-bold text-gray-900">
                {searchQuery ? `${t('matchingServicesFound')} (${filteredServices.length})` : t('orSelectManual')}
              </h3>
              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery('')}
                  className="text-xs text-blue-900 font-bold hover:underline"
                >
                  {t('clearSearch')}
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 max-h-[380px] overflow-y-auto pr-1">
              {filteredServices.map((svc) => {
                const isSelected = selectedService?.id === svc.id;
                const isEmergency = svc.category === 'Emergency Services';

                return (
                  <div
                    key={svc.id}
                    onClick={() => {
                      setSelectedService(svc);
                      setMatchedDiagnosis({
                        serviceName: svc.name,
                        trade: svc.category,
                        likelyParts: 'Standard ISI Hardware Toolkit',
                        standardTariff: 'Govt. Regulated',
                      });
                      if (isEmergency) {
                        setFormData((prev) => ({ ...prev, isEmergency: true }));
                      }
                    }}
                    className={`p-3.5 rounded-xl border cursor-pointer transition flex flex-col justify-between ${
                      isSelected
                        ? 'border-blue-950 bg-blue-50/60 ring-2 ring-blue-950 shadow-sm'
                        : isEmergency
                        ? 'border-red-200 bg-red-50/30 hover:border-red-400'
                        : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    <div>
                      <div className="flex items-center justify-between mb-1.5">
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded uppercase bg-gray-100 text-gray-700">
                          {svc.category}
                        </span>
                        {svc.is_complex ? (
                          <span className="text-[10px] font-bold text-amber-700 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200">
                            Master Paired
                          </span>
                        ) : null}
                      </div>
                      <h4 className="font-bold text-xs text-gray-900 mb-0.5">{svc.name}</h4>
                      <p className="text-[11px] text-gray-500 line-clamp-2">{svc.description}</p>
                    </div>

                    <div className="pt-2 mt-2 border-t border-gray-100 flex items-center justify-between text-xs">
                      <span className="text-gray-500 text-[10px]">{svc.available_workers || 3} {t('verifiedArtisans')}</span>
                      <span className="font-extrabold text-blue-950 font-mono">₹{svc.base_price}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="pt-3 flex items-center justify-between border-t border-gray-100">
            <span className="text-xs text-gray-500">
              {selectedService ? (
                <>Selected: <strong className="text-blue-950">{selectedService.name}</strong> (₹{selectedService.base_price})</>
              ) : 'Please select a service above'}
            </span>

            <button
              type="button"
              disabled={!selectedService}
              onClick={() => setCurrentStep(2)}
              className="btn btn-primary flex items-center gap-2 text-xs font-bold px-6 py-2.5 shadow-sm disabled:opacity-50"
            >
              <span>{t('btnContinueQuote')}</span> <ArrowRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHASE 2: QUOTE, BULK CONTRACT & SLOTTING
         ───────────────────────────────────────────────────────────── */}
      {currentStep === 2 && (
        <div className="bg-white p-6 md:p-8 rounded-2xl border border-gray-200 shadow-xs space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-gray-100">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-blue-900">Phase 2: Transparent Quote & Slot</span>
              <h2 className="text-lg font-bold text-gray-900">Configure Service Order & Schedule</h2>
              <p className="text-xs text-gray-500">Service: <strong className="text-blue-950">{selectedService?.name}</strong> (₹{selectedService?.base_price})</p>
            </div>
            <button
              onClick={() => setCurrentStep(1)}
              className="text-xs text-blue-900 hover:underline font-semibold"
            >
              Change Service
            </button>
          </div>

          <form onSubmit={handleStep2Next} className="space-y-4">
            {/* Bulk / Society Contract Discount Toggle */}
            <div className="p-4 rounded-xl border border-indigo-200 bg-indigo-50/40 flex items-start gap-3">
              <input
                type="checkbox"
                id="bulk-toggle"
                checked={formData.isBulkOrder}
                onChange={(e) => setFormData({ ...formData, isBulkOrder: e.target.checked })}
                className="h-4 w-4 mt-0.5 text-indigo-600 rounded focus:ring-indigo-500 border-gray-300"
              />
              <label htmlFor="bulk-toggle" className="cursor-pointer">
                <div className="text-xs font-bold text-indigo-950 flex items-center gap-1.5">
                  <Building2 size={14} className="text-indigo-700" />
                  Institutional / Apartment Society Bulk Contract (15% Cooperative Discount)
                </div>
                <p className="text-[11px] text-gray-600 mt-0.5">
                  Check this for residential society bulk maintenance or institutional facility orders to automatically apply the state cooperative master contract discount.
                </p>
              </label>
            </div>

            {/* Emergency Priority Toggle */}
            <div
              className={`p-4 rounded-xl border transition flex items-start gap-3 ${
                formData.isEmergency
                  ? 'bg-red-50 border-red-300'
                  : 'bg-amber-50/40 border-amber-200'
              }`}
            >
              <input
                type="checkbox"
                id="emergency-toggle"
                checked={formData.isEmergency}
                onChange={(e) => setFormData({ ...formData, isEmergency: e.target.checked })}
                className="h-4 w-4 mt-0.5 text-red-600 rounded focus:ring-red-500 border-gray-300"
              />
              <label htmlFor="emergency-toggle" className="cursor-pointer">
                <div className="text-xs font-bold text-gray-900 flex items-center gap-1.5">
                  <Zap size={14} className="text-red-600 fill-red-600" />
                  24/7 Priority Emergency (Express 30-Minute Dispatch)
                </div>
                <p className="text-[11px] text-gray-600 mt-0.5">
                  Instant priority dispatch to on-duty rapid response squad for high-risk water bursts, short-circuits, or safety hazards.
                </p>
              </label>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                  District *
                </label>
                <select
                  value={formData.district}
                  onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                  className="w-full p-2.5 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs bg-white"
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
                  placeholder="e.g. Patia, Saheed Nagar, College Square"
                  value={formData.city}
                  onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="sm:col-span-2">
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                  Street Address / Flat / Landmark *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. House No 42, Near DAV Public School"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                  Pincode *
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. 751024"
                  value={formData.pincode}
                  onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                  Preferred Date
                </label>
                <input
                  type="date"
                  value={formData.scheduledDate}
                  onChange={(e) => setFormData({ ...formData, scheduledDate: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                  Preferred Time Slot
                </label>
                <select
                  value={formData.scheduledTime}
                  onChange={(e) => setFormData({ ...formData, scheduledTime: e.target.value })}
                  className="w-full p-2.5 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs bg-white"
                >
                  <option value="09:00 AM">Morning (09:00 AM - 12:00 PM)</option>
                  <option value="02:00 PM">Afternoon (02:00 PM - 05:00 PM)</option>
                  <option value="06:00 PM">Evening (06:00 PM - 08:00 PM)</option>
                  <option value="Immediate">Immediate / Express 30-min</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                Specific Notes or Appliance Brand Details
              </label>
              <textarea
                rows={2}
                placeholder="e.g. Daikin Inverter AC, leaking from indoor unit tray..."
                value={formData.notes}
                onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                className="w-full p-2 border border-gray-300 rounded-md focus:outline-hidden focus:ring-2 focus:ring-blue-900 text-xs resize-none"
              />
            </div>

            <div className="pt-3 flex items-center justify-between border-t border-gray-100">
              <button
                type="button"
                onClick={() => setCurrentStep(1)}
                className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
              >
                <ArrowLeft size={14} /> Back
              </button>

              <button
                type="submit"
                className="btn btn-primary flex items-center gap-2 text-xs font-bold"
              >
                Continue to Choose Artisan <ArrowRight size={14} />
              </button>
            </div>
          </form>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHASE 3: CHOOSE WORKER OR AUTO-ASSIGN
         ───────────────────────────────────────────────────────────── */}
      {currentStep === 3 && (
        <div className="bg-white p-6 md:p-8 rounded-2xl border border-gray-200 shadow-xs space-y-6">
          <div className="flex items-start justify-between pb-3 border-b border-gray-100">
            <div>
              <span className="text-[11px] font-bold uppercase tracking-wider text-blue-900">
                Phase 3: Choose Your Cooperative Artisan
              </span>
              <h2 className="text-lg font-bold text-gray-900">Select Specific Artisan or Auto-Dispatch</h2>
              <p className="text-xs text-gray-500 mt-0.5">
                Every artisan is verified by the Labour Cooperative Federation with standard tariffs and background checks.
              </p>
            </div>
          </div>

          {/* Selection Mode Switch */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div
              onClick={() => {
                setAutoAssign(true);
                if (recommendedWorkers.length > 0) setSelectedWorker(recommendedWorkers[0]);
              }}
              className={`p-4 rounded-xl border-2 cursor-pointer transition flex items-center gap-3 ${
                autoAssign
                  ? 'border-blue-950 bg-blue-50/70 shadow-xs'
                  : 'border-gray-200 hover:border-gray-300 bg-gray-50'
              }`}
            >
              <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                autoAssign ? 'border-blue-950 bg-blue-950 text-white' : 'border-gray-400 bg-white'
              }`}>
                {autoAssign && <Check size={12} />}
              </div>
              <div>
                <div className="font-bold text-xs text-blue-950 flex items-center gap-1.5">
                  <Zap size={14} className="text-amber-600 fill-amber-500" />
                  Auto-Assign Nearest Top Artisan
                </div>
                <p className="text-[11px] text-gray-600">
                  Fastest acceptance based on real-time location & availability rotation.
                </p>
              </div>
            </div>

            <div
              onClick={() => setAutoAssign(false)}
              className={`p-4 rounded-xl border-2 cursor-pointer transition flex items-center gap-3 ${
                !autoAssign
                  ? 'border-blue-950 bg-blue-50/70 shadow-xs'
                  : 'border-gray-200 hover:border-gray-300 bg-gray-50'
              }`}
            >
              <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                !autoAssign ? 'border-blue-950 bg-blue-950 text-white' : 'border-gray-400 bg-white'
              }`}>
                {!autoAssign && <Check size={12} />}
              </div>
              <div>
                <div className="font-bold text-xs text-blue-950 flex items-center gap-1.5">
                  <User size={14} className="text-blue-900" />
                  Choose Specific Artisan from List Below
                </div>
                <p className="text-[11px] text-gray-600">
                  Pick your preferred artisan by experience, review score, or artisan tier.
                </p>
              </div>
            </div>
          </div>

          {matchingLoading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
              <p className="text-xs text-gray-600">Loading verified cooperative artisans...</p>
            </div>
          ) : recommendedWorkers.length === 0 ? (
            <div className="text-center py-8 bg-gray-50 rounded-xl border border-gray-200">
              <p className="text-xs text-gray-600">No specific workers in database yet. Click Auto-Assign to continue.</p>
            </div>
          ) : (
            <div className="space-y-3.5">
              <h3 className="text-xs font-bold uppercase tracking-wider text-gray-500">
                Available Verified Artisans in {formData.district}:
              </h3>

              {recommendedWorkers.map((worker) => {
                const isSelected = selectedWorker?.id === worker.id;

                return (
                  <div
                    key={worker.id}
                    onClick={() => {
                      setSelectedWorker(worker);
                      setAutoAssign(false);
                    }}
                    className={`p-4 rounded-xl border-2 cursor-pointer transition flex flex-col md:flex-row md:items-center justify-between gap-4 ${
                      isSelected
                        ? 'border-blue-950 bg-blue-50/50 ring-2 ring-blue-950/20'
                        : 'border-gray-200 hover:border-gray-300 bg-white'
                    }`}
                  >
                    <div className="flex items-start gap-3.5">
                      {/* Worker Avatar & Initials */}
                      <div className="w-12 h-12 rounded-xl bg-blue-950 text-white flex flex-col items-center justify-center shrink-0 shadow-xs">
                        <span className="font-bold text-sm">{worker.name?.charAt(0)}</span>
                        <span className="text-[8px] font-mono text-amber-400 uppercase">{worker.tier || 'MASTER'}</span>
                      </div>

                      <div>
                        <div className="flex items-center gap-2 flex-wrap">
                          <h4 className="font-bold text-sm text-gray-900">{worker.name}</h4>
                          <span className="font-mono text-[10px] bg-gray-100 text-gray-700 px-1.5 py-0.5 rounded">
                            {worker.worker_code}
                          </span>
                          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                            worker.tier === 'MASTER'
                              ? 'bg-amber-100 text-amber-900 border-amber-300'
                              : worker.tier === 'GOLD'
                              ? 'bg-yellow-100 text-yellow-900 border-yellow-300'
                              : 'bg-blue-100 text-blue-900 border-blue-300'
                          }`}>
                            {worker.tier || 'MASTER'} ARTISAN
                          </span>
                          <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-emerald-100 text-emerald-800">
                            ✓ Verified
                          </span>
                        </div>

                        <div className="text-[11px] text-gray-500 mt-1 flex items-center gap-3 flex-wrap">
                          <span>🏢 {worker.cooperative_name}</span>
                          <span>⭐ {worker.rating > 0 ? worker.rating.toFixed(1) : '4.8'} ({worker.total_reviews || 25} reviews)</span>
                          <span>⏳ {worker.experience_years} yrs exp</span>
                          <span className="text-emerald-700 font-semibold">🛡️ 7-Day Guarantee</span>
                        </div>

                        {/* Master Pairing Notification */}
                        {worker.masterPairing && (
                          <div className="mt-2 p-2 rounded-lg bg-amber-50 border border-amber-200 text-[11px] text-amber-900 flex items-center gap-1.5">
                            <Award className="w-3.5 h-3.5 text-amber-700 shrink-0" />
                            <span>Paired with Master Artisan <strong>{worker.masterPairing.masterName}</strong> (₹0 extra cost).</span>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="text-right shrink-0 flex md:flex-col items-center md:items-end justify-between">
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                        worker.availability === 'AVAILABLE'
                          ? 'bg-emerald-100 text-emerald-800'
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {worker.availability}
                      </span>
                      <button
                        type="button"
                        className={`mt-2 text-xs font-bold px-3 py-1.5 rounded-lg transition ${
                          isSelected
                            ? 'bg-blue-950 text-white'
                            : 'border border-blue-950 text-blue-950 hover:bg-blue-50'
                        }`}
                      >
                        {isSelected ? '✓ Selected Artisan' : 'Select Artisan'}
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          <div className="pt-3 flex items-center justify-between border-t border-gray-100">
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
              className="btn btn-primary flex items-center gap-2 text-xs font-bold"
            >
              Review Booking Summary <ArrowRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHASE 4: REVIEW & CONFIRM
         ───────────────────────────────────────────────────────────── */}
      {currentStep === 4 && (
        <div className="bg-white p-6 md:p-8 rounded-2xl border border-gray-200 shadow-xs space-y-6">
          <div className="pb-3 border-b border-gray-100">
            <span className="text-[11px] font-bold uppercase tracking-wider text-blue-900">
              Phase 4 & 5: Review & 90-5-5 Escrow Tariff Breakdown
            </span>
            <h2 className="text-lg font-bold text-gray-900">Confirm Order & Generate Security Handshake OTPs</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Left: Order & Artisan Summary */}
            <div className="space-y-3.5 text-xs">
              <div className="p-4 bg-gray-50 rounded-xl border border-gray-200 space-y-1.5">
                <div className="font-bold text-sm text-gray-900 flex items-center justify-between">
                  <span>{selectedService?.name}</span>
                  <span className="text-[10px] bg-blue-100 text-blue-900 px-2 py-0.5 rounded font-semibold">
                    {selectedService?.category}
                  </span>
                </div>
                <div className="text-gray-600">{selectedService?.description}</div>
                {formData.isBulkOrder && (
                  <div className="text-indigo-700 font-bold text-[11px]">
                    ✓ Bulk Society Master Contract Discount Applied (-15%)
                  </div>
                )}
                {formData.isEmergency && (
                  <div className="text-red-700 font-bold flex items-center gap-1 text-[11px]">
                    <Zap size={13} /> 24/7 Priority Emergency Active
                  </div>
                )}
              </div>

              {/* Chosen Worker Banner */}
              <div className="p-4 bg-blue-50/70 rounded-xl border border-blue-200 space-y-1">
                <div className="font-bold text-blue-950 flex items-center gap-1.5">
                  <User size={14} className="text-blue-900" />
                  {autoAssign ? 'Auto-Dispatched Artisan' : 'Selected Artisan'}
                </div>
                {selectedWorker ? (
                  <div className="text-gray-800 pt-1">
                    <div className="font-bold text-sm text-gray-900">{selectedWorker.name}</div>
                    <div className="text-gray-500 text-[11px]">
                      {selectedWorker.worker_code} • {selectedWorker.tier || 'MASTER'} ARTISAN • {selectedWorker.cooperative_name}
                    </div>
                  </div>
                ) : (
                  <div className="text-gray-600">Nearest available certified cooperative worker</div>
                )}
              </div>

              <div className="p-4 bg-gray-50 rounded-xl border border-gray-200 space-y-1">
                <div className="font-bold text-gray-900 flex items-center gap-1.5">
                  <MapPin size={14} className="text-blue-900" /> Destination & Schedule
                </div>
                <div className="text-gray-800 font-semibold">{formData.address}</div>
                <div className="text-gray-500">{formData.city}, {formData.district} - {formData.pincode}</div>
                <div className="text-gray-600 pt-1 font-medium">📅 {formData.scheduledDate} at {formData.scheduledTime}</div>
              </div>
            </div>

            {/* Right: Transparent 90-5-5 Split */}
            <div className="p-6 bg-blue-950 text-white rounded-2xl flex flex-col justify-between shadow-md">
              <div>
                <div className="text-xs font-bold uppercase tracking-wider text-amber-400 mb-3 flex items-center gap-1.5">
                  <ShieldCheck size={16} /> Transparent 90-5-5 Tariff
                </div>

                <div className="space-y-2.5 text-xs border-b border-white/15 pb-4 mb-4">
                  <div className="flex justify-between">
                    <span className="text-blue-200">Labour Base Charge:</span>
                    <span className="font-bold">₹{rawBasePrice.toFixed(2)}</span>
                  </div>
                  {formData.isBulkOrder && (
                    <div className="flex justify-between text-indigo-300">
                      <span>Society Contract Discount (15%):</span>
                      <span className="font-bold">-₹{bulkDiscount.toFixed(2)}</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span className="text-blue-200">Worker Welfare Fund (5%):</span>
                    <span className="font-bold">₹{coopFee.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-blue-200">Platform Infra & Operations (5%):</span>
                    <span className="font-bold">₹{platformFee.toFixed(2)}</span>
                  </div>
                </div>

                <div className="flex items-baseline justify-between text-base font-bold mb-3">
                  <span>Total Payable:</span>
                  <span className="text-2xl text-amber-400 font-mono">₹{totalEstimated.toFixed(2)}</span>
                </div>

                <div className="text-[10px] text-blue-200 bg-white/10 p-2.5 rounded-lg leading-relaxed space-y-0.5">
                  <div>• 90% goes directly to artisan wallet.</div>
                  <div>• 5% pools directly into ESIC accident & health insurance.</div>
                  <div>• 7-Day Free Repair Guarantee armed automatically upon completion.</div>
                </div>
              </div>

              <div className="mt-5 space-y-2">
                {!isAuthenticated ? (
                  <div className="p-3 bg-amber-500/20 rounded-xl border border-amber-400/40 text-center space-y-2">
                    <p className="text-xs text-amber-200">You must be signed in to confirm your booking.</p>
                    <Link
                      to="/login?role=customer"
                      className="w-full btn btn-saffron py-2.5 font-bold text-xs shadow-md flex items-center justify-center gap-1.5"
                    >
                      Sign In to Confirm Booking →
                    </Link>
                  </div>
                ) : (
                  <button
                    type="button"
                    disabled={loading}
                    onClick={handleConfirmBooking}
                    className="w-full btn btn-saffron py-3 font-bold text-sm shadow-md flex items-center justify-center gap-2"
                  >
                    {loading ? 'Submitting Order...' : 'Confirm Booking & Generate OTPs'}
                  </button>
                )}
              </div>
            </div>
          </div>

          <div className="pt-2 flex items-center justify-between border-t border-gray-100">
            <button
              type="button"
              onClick={() => setCurrentStep(3)}
              className="btn btn-secondary btn-sm flex items-center gap-1 text-xs"
            >
              <ArrowLeft size={14} /> Back
            </button>
          </div>
        </div>
      )}

      {/* ─────────────────────────────────────────────────────────────
          PHASE 5: SUCCESS WITH OTPS
         ───────────────────────────────────────────────────────────── */}
      {currentStep === 5 && createdBooking && (
        <div className="bg-white p-8 rounded-2xl border border-emerald-200 shadow-sm text-center max-w-xl mx-auto space-y-5">
          <div className="w-14 h-14 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center mx-auto">
            <CheckCircle2 size={32} />
          </div>

          <div>
            <h2 className="text-xl font-bold text-gray-900">Service Dispatched!</h2>
            <p className="text-xs text-gray-600 mt-0.5">
              Ref: <strong className="font-mono text-blue-950">{createdBooking.booking_code}</strong>
            </p>
          </div>

          {/* OTP Cards for Customer */}
          <div className="grid grid-cols-2 gap-3 max-w-sm mx-auto">
            <div className="p-3 bg-blue-50 rounded-xl border border-blue-200">
              <span className="text-[10px] font-bold text-blue-900 uppercase">Arrival OTP</span>
              <div className="text-xl font-bold font-mono text-blue-950 mt-1">
                {createdBooking.arrival_otp || '4821'}
              </div>
              <span className="text-[9px] text-gray-500">Give upon arrival</span>
            </div>
            <div className="p-3 bg-emerald-50 rounded-xl border border-emerald-200">
              <span className="text-[10px] font-bold text-emerald-900 uppercase">Completion OTP</span>
              <div className="text-xl font-bold font-mono text-emerald-950 mt-1">
                {createdBooking.completion_otp || '9156'}
              </div>
              <span className="text-[9px] text-gray-500">Give after work is done</span>
            </div>
          </div>

          <div className="flex justify-center gap-3 pt-2">
            <Link
              to={`/customer/bookings/${createdBooking.id}`}
              className="btn btn-primary font-semibold text-xs"
            >
              Track Live Order & Timeline →
            </Link>
            <Link
              to="/customer/bookings"
              className="btn btn-secondary font-semibold text-xs"
            >
              My Bookings
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
