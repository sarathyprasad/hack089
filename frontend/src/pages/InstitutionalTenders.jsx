import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { useAuth } from '../context/AuthContext';
import {
  Building2, Award, Briefcase, DollarSign, Users, CheckCircle2,
  AlertCircle, FileText, ArrowRight, ShieldCheck, Clock, Calendar
} from 'lucide-react';

export default function InstitutionalTenders() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [tenders, setTenders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user && user.role === 'WORKER') {
      navigate('/worker/dashboard', { replace: true });
      return;
    }
    if (user && user.role === 'CUSTOMER') {
      navigate('/customer/bookings', { replace: true });
      return;
    }
    api.getInstitutionalTenders()
      .then((res) => {
        setTenders(res.tenders || []);
      })
      .catch((err) => {
        console.error('Failed to load tenders:', err);
        setError(err.message || 'Failed to load tenders.');
      })
      .finally(() => setLoading(false));
  }, [user]);

  if (loading) {
    return (
      <div className="container py-16 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-2"></div>
        <p className="text-xs text-gray-500">Loading institutional tenders and bids...</p>
      </div>
    );
  }

  return (
    <div className="container py-8 max-w-5xl mx-auto space-y-6">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-950 via-slate-900 to-indigo-950 rounded-2xl p-6 md:p-8 text-white shadow-md space-y-3">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-200 text-xs font-bold uppercase tracking-wider">
          <Briefcase size={14} className="text-amber-400" />
          Institutional Contracts & Public Works
        </div>
        <h1 className="text-2xl md:text-3xl font-extrabold text-white">
          Institutional Tenders, Bids & Multi-Artisan Projects
        </h1>
        <p className="text-xs md:text-sm text-blue-200 max-w-3xl">
          NLCF-affiliated and registered federations gain priority access to bid for municipal civic maintenance, railway quarters overhauls, and institutional facility contracts.
        </p>

        <div className="pt-2 flex flex-wrap gap-2">
          <Link to="/federation/portal" className="btn btn-secondary btn-sm text-xs font-bold">
            ← Federation Portal
          </Link>
          <Link to="/society/register" className="btn btn-primary btn-sm text-xs font-bold">
            Society Registration Wizard →
          </Link>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-xl bg-red-50 border border-red-200 text-red-800 text-xs flex items-start gap-2">
          <AlertCircle size={16} className="shrink-0 mt-0.5 text-red-600" />
          <div>{error}</div>
        </div>
      )}

      {/* Tenders Grid */}
      <div className="space-y-4">
        {tenders.map((t) => (
          <div
            key={t.id}
            className="bg-white rounded-2xl border border-gray-200 p-6 shadow-xs hover:shadow-md transition space-y-4"
          >
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-gray-100 pb-3">
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-mono text-xs font-bold text-blue-900">{t.tender_code}</span>
                  <span className={`px-2.5 py-0.5 rounded text-[10px] font-extrabold uppercase ${
                    t.status === 'AWARDED' ? 'bg-emerald-100 text-emerald-900' :
                    t.status === 'IN_PROGRESS' ? 'bg-blue-100 text-blue-900' : 'bg-amber-100 text-amber-900'
                  }`}>
                    {t.status}
                  </span>
                </div>
                <h3 className="text-sm md:text-base font-bold text-gray-900 mt-1">{t.title}</h3>
                <p className="text-xs text-gray-500">Issuing Authority: <strong className="text-gray-800">{t.issuing_authority}</strong> ({t.district})</p>
              </div>

              <div className="text-right shrink-0">
                <span className="text-[11px] text-gray-500 block">Estimated Tender Value</span>
                <span className="text-xl font-extrabold text-blue-950 font-mono">
                  ₹{t.estimated_value?.toLocaleString()}
                </span>
              </div>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
              <div className="p-3 rounded-xl bg-gray-50 border border-gray-100">
                <span className="text-gray-500 text-[10px] uppercase font-semibold block">Category</span>
                <strong className="text-gray-900">{t.category}</strong>
              </div>

              <div className="p-3 rounded-xl bg-gray-50 border border-gray-100">
                <span className="text-gray-500 text-[10px] uppercase font-semibold block">Affiliation Prerequisite</span>
                <span className={`font-bold ${t.requires_nlcf_affiliation ? 'text-amber-800' : 'text-gray-800'}`}>
                  {t.requires_nlcf_affiliation ? '🌟 NLCF Affiliation Mandatory' : 'Open to All Federations'}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-emerald-50/50 border border-emerald-200">
                <span className="text-emerald-800 text-[10px] uppercase font-semibold block">Funds Received</span>
                <strong className="text-emerald-950 font-mono">₹{t.funds_received?.toLocaleString()}</strong>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 border border-slate-200">
                <span className="text-slate-700 text-[10px] uppercase font-semibold block">Due Remaining</span>
                <strong className="text-slate-950 font-mono">₹{t.due_remaining?.toLocaleString()}</strong>
              </div>
            </div>

            {t.awarded_society_name && (
              <div className="p-3 rounded-xl bg-blue-50/60 border border-blue-200 text-xs flex items-center justify-between">
                <span className="text-blue-950 font-semibold flex items-center gap-1.5">
                  <Award size={14} className="text-blue-700" /> Awarded Federation: <strong>{t.awarded_society_name}</strong>
                </span>
                <span className="text-[11px] text-blue-900 font-mono font-bold">
                  {t.allocated_workers_count} Assigned Artisans
                </span>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
