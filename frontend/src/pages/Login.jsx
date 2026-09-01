import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  Lock, Mail, ShieldCheck, UserCheck, Briefcase, Building,
  AlertCircle, ArrowRight
} from 'lucide-react';

export default function Login() {
  const { login, error } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [searchParams] = useSearchParams();

  // Selected Portal: 'CUSTOMER' | 'WORKER' | 'ADMIN'
  const initialRole = searchParams.get('role') === 'worker' ? 'WORKER' : searchParams.get('role') === 'admin' ? 'ADMIN' : 'CUSTOMER';
  const [activePortal, setActivePortal] = useState(initialRole);

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [localError, setLocalError] = useState('');
  const [suggestedPortal, setSuggestedPortal] = useState(null);

  const from = location.state?.from?.pathname || '/';

  // Sync email default when tab changes
  useEffect(() => {
    setEmail('');
    setPassword('');
    setLocalError('');
    setSuggestedPortal(null);
  }, [activePortal]);

  const handleLogin = async (e) => {
    if (e) e.preventDefault();
    setLocalError('');
    setSuggestedPortal(null);
    setLoading(true);
    try {
      const user = await login(email, password, activePortal);
      redirectUser(user);
    } catch (err) {
      const msg = err.message || 'Invalid credentials';
      setLocalError(msg);
      if (msg.includes('Citizen / Customer') || msg.includes('Citizen portal')) {
        setSuggestedPortal('CUSTOMER');
      } else if (msg.includes('Worker Member') || msg.includes('Worker portal')) {
        setSuggestedPortal('WORKER');
      } else if (msg.includes('Admin privileges') || msg.includes('Admin portal')) {
        setSuggestedPortal('ADMIN');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleQuickDemoLogin = async (roleKey) => {
    setLocalError('');
    setSuggestedPortal(null);
    setLoading(true);
    try {
      let demoEmail = 'customer@demo.local';
      let demoPortal = 'CUSTOMER';
      if (roleKey === 'WORKER') {
        demoEmail = 'ramesh.w@demo.local';
        demoPortal = 'WORKER';
      } else if (roleKey === 'ADMIN') {
        demoEmail = 'admin@demo.local';
        demoPortal = 'ADMIN';
      }
      setEmail(demoEmail);
      setPassword('demo123');
      const user = await login(demoEmail, 'demo123', demoPortal);
      redirectUser(user);
    } catch (err) {
      setLocalError(err.message || 'Demo login failed');
    } finally {
      setLoading(false);
    }
  };

  const redirectUser = (user) => {
    if (user.role === 'COOPERATIVE_ADMIN') {
      navigate('/admin/dashboard');
    } else if (user.role === 'WORKER') {
      navigate('/worker/dashboard');
    } else {
      navigate(from === '/' ? '/customer/bookings' : from);
    }
  };

  // Portal theme configs
  const portalConfigs = {
    CUSTOMER: {
      title: 'Citizen / Customer Portal',
      subtitle: 'Sign in to book verified cooperative services, track active orders, pay securely, and download Form IV tax invoices.',
      badgeText: 'Citizen Access',
      badgeClass: 'bg-blue-100 text-blue-900 border-blue-200',
      btnColor: 'bg-blue-900 hover:bg-blue-950 text-white',
      registerLink: '/register?role=customer',
      registerText: 'New citizen? Create an account here',
      demoLabel: 'Demo Citizen (Ananya Patel)',
      demoEmail: 'customer@demo.local',
    },
    WORKER: {
      title: 'Worker Member Portal',
      subtitle: 'Sign in to manage on-duty availability, accept incoming dispatches, view daily earnings, and access social security welfare.',
      badgeText: 'Worker Member Access',
      badgeClass: 'bg-green-100 text-green-900 border-green-200',
      btnColor: 'bg-green-700 hover:bg-green-800 text-white',
      registerLink: '/register?role=worker',
      registerText: 'Skilled artisan? Register with your local cooperative federation',
      demoLabel: 'Demo Worker (Ramesh Kumar - Electrician)',
      demoEmail: 'ramesh.w@demo.local',
    },
    ADMIN: {
      title: 'Cooperative Federation Admin',
      subtitle: 'Official federation administrator portal for worker credential verification, dispute arbitration, and dispatch oversight.',
      badgeText: 'Federation Authority',
      badgeClass: 'bg-amber-100 text-amber-900 border-amber-200',
      btnColor: 'bg-amber-600 hover:bg-amber-700 text-white',
      registerLink: '/help',
      registerText: 'Federation officer? Contact State Registrar for administrative access',
      demoLabel: 'Demo Admin (Arun Pattnaik - Federation Admin)',
      demoEmail: 'admin@demo.local',
    },
  };

  const currentConfig = portalConfigs[activePortal];

  return (
    <div className="container py-10 max-w-2xl mx-auto px-4">
      {/* Top Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-blue-950 text-white mb-2 shadow-md">
          <ShieldCheck size={26} />
        </div>
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900">
          Shram Setu Single Sign-On
        </h1>
        <p className="text-xs md:text-sm text-gray-500 mt-1 max-w-lg mx-auto">
          Official Government Cooperative Labour Services Portal
        </p>
      </div>

      {/* ── 3 Separate Portal Selection Tabs ── */}
      <div className="grid grid-cols-3 gap-2 sm:gap-4 mb-6">
        {/* Customer Tab */}
        <button
          type="button"
          onClick={() => setActivePortal('CUSTOMER')}
          className={`p-3 rounded-xl border-2 transition text-center flex flex-col items-center gap-1.5 ${
            activePortal === 'CUSTOMER'
              ? 'border-blue-900 bg-blue-50 shadow-sm ring-2 ring-blue-900/20'
              : 'border-gray-200 bg-white hover:bg-gray-50 text-gray-600'
          }`}
        >
          <div className={`p-1.5 rounded-lg ${activePortal === 'CUSTOMER' ? 'bg-blue-900 text-white' : 'bg-gray-100 text-gray-600'}`}>
            <UserCheck size={18} />
          </div>
          <div className={`font-bold text-xs ${activePortal === 'CUSTOMER' ? 'text-blue-950' : 'text-gray-800'}`}>
            Citizen
          </div>
        </button>

        {/* Worker Tab */}
        <button
          type="button"
          onClick={() => setActivePortal('WORKER')}
          className={`p-3 rounded-xl border-2 transition text-center flex flex-col items-center gap-1.5 ${
            activePortal === 'WORKER'
              ? 'border-green-700 bg-green-50 shadow-sm ring-2 ring-green-700/20'
              : 'border-gray-200 bg-white hover:bg-gray-50 text-gray-600'
          }`}
        >
          <div className={`p-1.5 rounded-lg ${activePortal === 'WORKER' ? 'bg-green-700 text-white' : 'bg-gray-100 text-gray-600'}`}>
            <Briefcase size={18} />
          </div>
          <div className={`font-bold text-xs ${activePortal === 'WORKER' ? 'text-green-950' : 'text-gray-800'}`}>
            Worker
          </div>
        </button>

        {/* Admin Tab */}
        <button
          type="button"
          onClick={() => setActivePortal('ADMIN')}
          className={`p-3 rounded-xl border-2 transition text-center flex flex-col items-center gap-1.5 ${
            activePortal === 'ADMIN'
              ? 'border-amber-600 bg-amber-50 shadow-sm ring-2 ring-amber-600/20'
              : 'border-gray-200 bg-white hover:bg-gray-50 text-gray-600'
          }`}
        >
          <div className={`p-1.5 rounded-lg ${activePortal === 'ADMIN' ? 'bg-amber-600 text-white' : 'bg-gray-100 text-gray-600'}`}>
            <Building size={18} />
          </div>
          <div className={`font-bold text-xs ${activePortal === 'ADMIN' ? 'text-amber-950' : 'text-gray-800'}`}>
            Coop Admin
          </div>
        </button>
      </div>

      {/* ── Main Clean Login Panel ── */}
      <div className="bg-white p-6 md:p-8 rounded-2xl border border-gray-200 shadow-sm space-y-5">
        {/* Active Portal Header */}
        <div className="pb-4 border-b border-gray-100">
          <span className={`inline-block text-[10px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded border mb-1.5 ${currentConfig.badgeClass}`}>
            {currentConfig.badgeText}
          </span>
          <h2 className="text-lg font-bold text-gray-900">
            {currentConfig.title}
          </h2>
          <p className="text-xs text-gray-500 mt-1 leading-relaxed">
            {currentConfig.subtitle}
          </p>
        </div>

        {/* 1-Click Quick Demo Login Button for Active Portal */}
        <div className="p-3 bg-gray-50 rounded-xl border border-gray-200 flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs">
          <div>
            <span className="text-[10px] uppercase font-bold text-gray-500 block">Pre-Configured Demo Account</span>
            <span className="font-semibold text-gray-800">{currentConfig.demoLabel}</span>
            <span className="text-gray-500 text-[11px] block">{currentConfig.demoEmail} / demo123</span>
          </div>
          <button
            type="button"
            disabled={loading}
            onClick={() => handleQuickDemoLogin(activePortal)}
            className="btn btn-secondary btn-sm text-xs font-bold shrink-0 self-start sm:self-auto border-blue-300 text-blue-900 hover:bg-blue-50"
          >
            ⚡ 1-Click Sign In
          </button>
        </div>

        {(localError || error) && (
          <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-red-800 text-xs space-y-2">
            <div className="flex items-center gap-2">
              <AlertCircle size={16} className="shrink-0 text-red-600" />
              <span>{localError || error}</span>
            </div>
            {suggestedPortal && suggestedPortal !== activePortal && (
              <div className="pt-1 border-t border-red-200/60 flex items-center justify-between">
                <span className="text-red-700 font-medium">Click here to switch portal:</span>
                <button
                  type="button"
                  onClick={() => setActivePortal(suggestedPortal)}
                  className="px-2.5 py-1 rounded-lg bg-red-800 text-white font-bold text-[11px] hover:bg-red-900 transition"
                >
                  Switch to {suggestedPortal === 'CUSTOMER' ? 'Citizen' : suggestedPortal === 'WORKER' ? 'Worker' : 'Admin'} Portal →
                </button>
              </div>
            )}
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-[11px] font-bold text-gray-700 uppercase tracking-wider mb-1">
              {activePortal === 'WORKER' ? 'Worker Registered Email / ID' : activePortal === 'ADMIN' ? 'Official Admin Email' : 'Citizen Email Address'}
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
                <Mail size={16} />
              </div>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pl-9 pr-3 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                placeholder={activePortal === 'WORKER' ? 'worker@coop.local' : activePortal === 'ADMIN' ? 'admin@coop.local' : 'citizen@email.com'}
              />
            </div>
          </div>

          <div>
            <label className="block text-[11px] font-bold text-gray-700 uppercase tracking-wider mb-1">
              Password
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
                <Lock size={16} />
              </div>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full pl-9 pr-3 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-900 text-xs"
                placeholder="••••••••"
              />
            </div>
          </div>

          <div className="pt-2">
            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 rounded-xl font-bold text-xs shadow-sm transition flex items-center justify-center gap-2 ${currentConfig.btnColor}`}
            >
              {loading ? 'Authenticating...' : `Sign In to ${currentConfig.title}`}
              <ArrowRight size={14} />
            </button>
          </div>
        </form>

        <div className="text-center pt-3 border-t border-gray-100">
          <Link
            to={currentConfig.registerLink}
            className="text-xs text-blue-900 font-semibold hover:underline"
          >
            {currentConfig.registerText} →
          </Link>
        </div>
      </div>
    </div>
  );
}
