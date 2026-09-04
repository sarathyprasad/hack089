import React, { useState } from 'react';
import {
  HelpCircle, PhoneCall, ShieldAlert, MessageSquare, ChevronDown,
  ChevronUp, CheckCircle2, AlertCircle, FileText, Send
} from 'lucide-react';

const FAQS = [
  {
    q: 'How does Shram Setu verify worker credentials?',
    a: 'Every worker registered on Shram Setu is affiliated with a licensed District Labour Cooperative. Accredited ITI certificates, NSDC skill cards, and state trade licenses are physically and digitally verified by the Cooperative Administration before activation.',
  },
  {
    q: 'What is the pricing model? Are there hidden fees?',
    a: 'Prices are standardized based on National Labour Board notifications. Customers pay a transparent base fee (93% worker labour) + 5% PF & insurance contribution and 2% platform administration fee. There are no surge prices or dynamic algorithmic inflation.',
  },
  {
    q: 'How do emergency bookings work?',
    a: 'Emergency service requests (e.g. electrical short circuits, major pipe bursts) are instantly routed with highest priority to the nearest available verified cooperative worker with an average response time of under 60 minutes in urban centers.',
  },
  {
    q: 'How are workers compensated?',
    a: 'Under our transparent 93-2-5 model, 93% of every transaction amount goes directly to the worker. 5% is directed to PF & Insurance (ESIC insurance, pension, social security), and 2% covers digital platform infrastructure.',
  },
  {
    q: 'What if I am not satisfied with the work?',
    a: 'You can submit feedback and rating directly from your dashboard. The District Labour Cooperative officer investigates any grievance with an on-ground rework or refund policy under cooperative quality assurance rules.',
  },
];

export default function Help() {
  const [openFaq, setOpenFaq] = useState(0);
  const [ticketSubmitted, setTicketSubmitted] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    category: 'Booking Issue',
    description: '',
  });

  const handleTicketSubmit = (e) => {
    e.preventDefault();
    setTicketSubmitted(true);
  };

  return (
    <div className="container py-10 max-w-5xl mx-auto">
      {/* Header */}
      <div className="text-center max-w-3xl mx-auto mb-10">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-100 text-blue-900 text-xs font-bold uppercase tracking-wider mb-3">
          <HelpCircle size={14} /> Public Support & Grievance Redressal
        </div>
        <h1 className="text-3xl font-bold text-gray-900">
          Help & Grievance Support Centre
        </h1>
        <p className="text-sm text-gray-600 mt-2">
          Find answers, contact district cooperative helplines, or submit a resolution ticket.
        </p>
      </div>

      {/* Emergency & Helpline Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-12">
        <div className="bg-red-50 p-6 rounded-xl border border-red-200 text-red-950 flex flex-col justify-between">
          <div>
            <div className="w-10 h-10 rounded-full bg-red-600 text-white flex items-center justify-center mb-3">
              <ShieldAlert size={20} />
            </div>
            <h3 className="font-bold text-sm mb-1">Emergency Dispatch Helpline</h3>
            <p className="text-xs text-red-800 leading-relaxed mb-3">
              For urgent electrical faults, pipe bursts, or crisis assistance:
            </p>
          </div>
          <div>
            <div className="text-lg font-bold font-mono text-red-700">1800-345-7788</div>
            <div className="text-[10px] text-red-600 font-semibold uppercase tracking-wider">Toll-Free • 24/7 Available</div>
          </div>
        </div>

        <div className="bg-blue-50 p-6 rounded-xl border border-blue-200 text-blue-950 flex flex-col justify-between">
          <div>
            <div className="w-10 h-10 rounded-full bg-blue-900 text-white flex items-center justify-center mb-3">
              <PhoneCall size={20} />
            </div>
            <h3 className="font-bold text-sm mb-1">Cooperative Federation Helpdesk</h3>
            <p className="text-xs text-blue-800 leading-relaxed mb-3">
              For general booking inquiries, worker verification, and membership:
            </p>
          </div>
          <div>
            <div className="text-lg font-bold font-mono text-blue-900">0674-254-0001</div>
            <div className="text-[10px] text-blue-700 font-semibold uppercase tracking-wider">Mon - Sat • 9:00 AM - 6:00 PM</div>
          </div>
        </div>

        <div className="bg-green-50 p-6 rounded-xl border border-green-200 text-green-950 flex flex-col justify-between">
          <div>
            <div className="w-10 h-10 rounded-full bg-green-800 text-white flex items-center justify-center mb-3">
              <MessageSquare size={20} />
            </div>
            <h3 className="font-bold text-sm mb-1">Worker Welfare Grievance</h3>
            <p className="text-xs text-green-800 leading-relaxed mb-3">
              For registered cooperative workers needing insurance or wage assistance:
            </p>
          </div>
          <div>
            <div className="text-lg font-bold font-mono text-green-800">1800-112-9900</div>
            <div className="text-[10px] text-green-700 font-semibold uppercase tracking-wider">Cooperative Welfare Board</div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-12 gap-8">
        {/* FAQs */}
        <div className="md:col-span-7">
          <h2 className="text-xl font-bold text-gray-900 mb-4 pb-2 border-b border-gray-200">
            Frequently Asked Questions
          </h2>
          <div className="space-y-3">
            {FAQS.map((faq, idx) => (
              <div
                key={idx}
                className="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-2xs"
              >
                <button
                  type="button"
                  onClick={() => setOpenFaq(openFaq === idx ? null : idx)}
                  className="w-full text-left p-4 flex items-center justify-between gap-3 text-sm font-semibold text-gray-900 hover:bg-gray-50 transition"
                >
                  <span>{faq.q}</span>
                  {openFaq === idx ? (
                    <ChevronUp size={16} className="text-blue-900 shrink-0" />
                  ) : (
                    <ChevronDown size={16} className="text-gray-400 shrink-0" />
                  )}
                </button>

                {openFaq === idx && (
                  <div className="px-4 pb-4 text-xs text-gray-600 leading-relaxed border-t border-gray-100 pt-3 bg-gray-50/50">
                    {faq.a}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Support Ticket Simulation */}
        <div className="md:col-span-5">
          <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-xs">
            <h3 className="text-base font-bold text-gray-900 mb-2 flex items-center gap-2">
              <FileText size={18} className="text-blue-900" /> Submit a Grievance Ticket
            </h3>
            <p className="text-xs text-gray-500 mb-4">
              Our cooperative officer will contact you within 24 business hours.
            </p>

            {ticketSubmitted ? (
              <div className="p-5 bg-green-50 rounded-lg border border-green-200 text-center">
                <CheckCircle2 size={32} className="mx-auto text-green-700 mb-2" />
                <h4 className="font-bold text-sm text-green-950 mb-1">Grievance Ticket Registered</h4>
                <p className="text-xs text-green-800 mb-2">
                  Ticket ID: <span className="font-mono font-bold">GRV-2026-0894</span>
                </p>
                <p className="text-[11px] text-gray-600">
                  (POC Simulation: In production this connects to state cooperative grievance CRM)
                </p>
                <button
                  type="button"
                  onClick={() => setTicketSubmitted(false)}
                  className="mt-4 text-xs text-blue-900 font-semibold underline"
                >
                  Submit another ticket
                </button>
              </div>
            ) : (
              <form onSubmit={handleTicketSubmit} className="space-y-3 text-xs">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Your Name</label>
                  <input
                    type="text"
                    required
                    placeholder="Full name"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Contact Phone</label>
                  <input
                    type="tel"
                    required
                    placeholder="Mobile number"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-900"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Grievance Category</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-900 bg-white"
                  >
                    <option value="Booking Issue">Booking or Scheduling Issue</option>
                    <option value="Worker Quality">Worker Quality / Behavior</option>
                    <option value="Payment Dispute">Payment or Invoice Discrepancy</option>
                    <option value="Worker Welfare Claim">Worker Welfare / Insurance Claim</option>
                    <option value="Other">Other Query</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Describe Issue</label>
                  <textarea
                    rows={3}
                    required
                    placeholder="Provide details..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-900 resize-none"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full btn btn-primary py-2 text-xs font-semibold flex items-center justify-center gap-1.5 shadow-xs"
                >
                  <Send size={13} /> Submit Ticket
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
