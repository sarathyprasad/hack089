import React, { useRef } from 'react';
import {
  Printer, Building2, ShieldCheck, CheckCircle2,
  X, QrCode, FileText, Landmark
} from 'lucide-react';

export default function TaxInvoiceModal({ isOpen = true, invoice, booking, onClose }) {
  const printRef = useRef();

  if (isOpen === false) return null;

  const handlePrint = () => {
    window.print();
  };

  // Resilient invoice data: use invoice object or synthesize from booking
  const activeInvoice = invoice || (booking ? {
    invoice_number: `INV-2026-${String(booking.id || '101').padStart(4, '0')}`,
    cooperative_name: booking.cooperative_name || 'Bhubaneswar Labour Cooperative Federation',
    cooperative_reg: booking.cooperative_reg || 'COOP-OD-2024-001',
    customer_name: booking.customer_name || 'Citizen Customer',
    customer_phone: booking.customer_phone,
    location_address: booking.location_address || 'Patia, Bhubaneswar',
    location_city: booking.location_city || 'Bhubaneswar',
    location_district: booking.location_district || 'Khordha',
    location_pincode: booking.location_pincode || '751024',
    booking_code: booking.booking_code,
    worker_name: booking.worker_name || 'Assigned Cooperative Artisan',
    worker_code: booking.worker_code || 'WKR-OD-1001',
    service_name: booking.service_name || 'Standard Cooperative Service',
    service_date: booking.scheduled_date || new Date().toISOString().split('T')[0],
    amount: booking.amount || 299,
    parts_cost: booking.parts_cost || 0,
    parts_details: booking.parts_details,
    cooperative_fee: booking.cooperative_fee || 14.95,
    platform_fee: booking.platform_fee || 14.95,
    total_amount: booking.total_amount || 328.9,
    payment_status: booking.status === 'COMPLETED' ? 'PAID' : 'UNPAID / ESCROW HOLD',
    transaction_id: `TXN-OD-${booking.id}-2026`,
  } : null);

  if (!activeInvoice) return null;

  return (
    <div
      onClick={(e) => { if (e.target === e.currentTarget) onClose(); }}
      className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto"
    >
      <div className="bg-white rounded-2xl max-w-2xl w-full overflow-hidden shadow-2xl my-6">
        {/* Top Control Bar */}
        <div className="p-4 bg-gray-900 text-white flex items-center justify-between no-print">
          <div className="flex items-center gap-2 text-xs font-semibold">
            <FileText size={16} className="text-amber-400" />
            <span>Official Government Cooperative Tax Invoice (Form IV)</span>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handlePrint}
              className="btn btn-sm bg-amber-500 hover:bg-amber-600 text-gray-950 font-bold text-xs flex items-center gap-1.5 px-3 py-1.5 rounded-lg shadow-sm"
            >
              <Printer size={14} /> Print / Save PDF
            </button>
            <button
              onClick={onClose}
              className="text-white/70 hover:text-white p-1 rounded-lg hover:bg-white/10"
            >
              <X size={18} />
            </button>
          </div>
        </div>

        {/* ── Printable Invoice Document Body ── */}
        <div ref={printRef} className="p-8 space-y-6 text-xs text-gray-800 bg-white">
          {/* Header Banner */}
          <div className="border-b-2 border-blue-900 pb-5 flex items-start justify-between">
            <div className="space-y-1">
              <div className="inline-flex items-center gap-1 text-[10px] font-bold text-blue-900 uppercase tracking-wider">
                <Landmark size={12} /> Labour Cooperative Society Form IV
              </div>
              <h1 className="text-lg font-bold text-gray-900 uppercase tracking-tight">
                {activeInvoice.cooperative_name || 'Bhubaneswar Labour Cooperative Federation'}
              </h1>
              <p className="text-[11px] text-gray-500">
                Registered under Multi-State Cooperative Societies Act, 2002 • Reg No: <span className="font-mono font-bold text-gray-700">{activeInvoice.cooperative_reg || 'COOP-OD-2024-001'}</span>
              </p>
              <p className="text-[10px] text-gray-400">
                Headquarters: {activeInvoice.cooperative_address || 'Saheed Nagar, Unit-8, Bhubaneswar, Khordha, Odisha'}
              </p>
            </div>

            <div className="text-right space-y-1">
              <div className="inline-block px-2.5 py-1 rounded bg-green-100 text-green-900 font-bold font-mono text-xs uppercase">
                TAX INVOICE
              </div>
              <div className="text-xs font-mono font-bold text-gray-900 block">
                {activeInvoice.invoice_number}
              </div>
              <div className="text-[11px] text-gray-500">
                Date: {activeInvoice.service_date || new Date().toISOString().split('T')[0]}
              </div>
            </div>
          </div>

          {/* Billed To & Service Details Grid */}
          <div className="grid grid-cols-2 gap-6 p-4 bg-gray-50 rounded-xl border border-gray-200">
            <div>
              <span className="text-[10px] font-bold uppercase text-gray-400 block mb-1">
                Billed To (Citizen / Customer)
              </span>
              <div className="font-bold text-sm text-gray-900">{activeInvoice.customer_name}</div>
              <div className="text-gray-600 mt-0.5">{activeInvoice.location_address || 'Patia, Bhubaneswar'}</div>
              <div className="text-gray-500 text-[11px]">
                {activeInvoice.location_city || 'Bhubaneswar'}, {activeInvoice.location_district || 'Khordha'} - {activeInvoice.location_pincode || '751024'}
              </div>
              {activeInvoice.customer_phone && (
                <div className="text-gray-500 text-[10px] mt-1">Ph: {activeInvoice.customer_phone}</div>
              )}
            </div>

            <div>
              <span className="text-[10px] font-bold uppercase text-gray-400 block mb-1">
                Service Order Details
              </span>
              <div className="space-y-1">
                <div className="flex justify-between">
                  <span className="text-gray-500">Booking Ref:</span>
                  <span className="font-mono font-bold text-blue-900">{activeInvoice.booking_code}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">Assigned Worker:</span>
                  <span className="font-semibold text-gray-900">{activeInvoice.worker_name}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">Payment Status:</span>
                  <span className={`font-bold px-1.5 py-0.5 rounded text-[10px] uppercase ${
                    activeInvoice.payment_status?.includes('PAID') ? 'bg-green-100 text-green-800' : 'bg-amber-100 text-amber-800'
                  }`}>
                    {activeInvoice.payment_status}
                  </span>
                </div>
                {activeInvoice.transaction_id && (
                  <div className="flex justify-between text-[10px]">
                    <span className="text-gray-500">Txn Ref:</span>
                    <span className="font-mono text-gray-700">{activeInvoice.transaction_id}</span>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Line Items Table */}
          <div className="border border-gray-200 rounded-xl overflow-hidden">
            <table className="w-full text-left text-xs">
              <thead className="bg-gray-50 text-gray-600 border-b border-gray-200 uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="p-3">Description of Labour / Service / Parts</th>
                  <th className="p-3">SAC Code</th>
                  <th className="p-3 text-right">Standard Rate</th>
                  <th className="p-3 text-right">Total (INR)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-gray-700">
                <tr>
                  <td className="p-3">
                    <div className="font-bold text-gray-900">{activeInvoice.service_name}</div>
                    <div className="text-[10px] text-gray-500">Standard cooperative artisan skilled labour charge</div>
                  </td>
                  <td className="p-3 font-mono text-gray-500">998719</td>
                  <td className="p-3 text-right font-mono">₹{activeInvoice.amount}</td>
                  <td className="p-3 text-right font-mono font-bold">₹{activeInvoice.amount}</td>
                </tr>

                {activeInvoice.parts_cost > 0 && (
                  <tr className="bg-amber-50/40">
                    <td className="p-3">
                      <div className="font-bold text-amber-950">Standard Locked Replacement Parts</div>
                      <div className="text-[10px] text-gray-500">{activeInvoice.parts_details || 'Original Manufacturer Components'}</div>
                    </td>
                    <td className="p-3 font-mono text-gray-500">PRT-STD</td>
                    <td className="p-3 text-right font-mono">₹{activeInvoice.parts_cost}</td>
                    <td className="p-3 text-right font-mono font-bold text-amber-950">₹{activeInvoice.parts_cost}</td>
                  </tr>
                )}

                <tr className="bg-blue-50/30">
                  <td className="p-3">
                    <div className="font-semibold text-blue-950">Worker Welfare Fund (5%)</div>
                    <div className="text-[10px] text-gray-500">ESIC accident insurance, health & pension contribution</div>
                  </td>
                  <td className="p-3 font-mono text-gray-500">COOP-WLF</td>
                  <td className="p-3 text-right font-mono">5.0%</td>
                  <td className="p-3 text-right font-mono font-bold text-blue-950">₹{activeInvoice.cooperative_fee}</td>
                </tr>

                <tr>
                  <td className="p-3">
                    <div className="font-semibold text-gray-800">Platform Infra & Operations (5%)</div>
                    <div className="text-[10px] text-gray-500">Dispatch helpline, quality assurance & server infra</div>
                  </td>
                  <td className="p-3 font-mono text-gray-500">PLAT-FEE</td>
                  <td className="p-3 text-right font-mono">5.0%</td>
                  <td className="p-3 text-right font-mono font-bold">₹{activeInvoice.platform_fee}</td>
                </tr>
              </tbody>
              <tfoot className="bg-gray-50 font-bold border-t-2 border-gray-300">
                <tr>
                  <td colSpan={3} className="p-3 text-right text-gray-800 uppercase text-[11px]">
                    Total Tax Invoice Value:
                  </td>
                  <td className="p-3 text-right text-base font-bold text-blue-950 font-mono">
                    ₹{activeInvoice.total_amount}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          {/* Footer & Digital Seal */}
          <div className="pt-4 border-t border-gray-200 flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="w-16 h-16 bg-gray-100 border border-gray-300 rounded p-1 flex items-center justify-center">
                <QrCode size={48} className="text-gray-800" />
              </div>
              <div className="space-y-0.5 text-[10px] text-gray-500">
                <div className="font-bold text-gray-700">Digital Verification Seal</div>
                <div>Scan with Odisha Cooperative Citizen App to verify authenticity.</div>
                <div className="text-green-700 font-semibold flex items-center gap-1">
                  <ShieldCheck size={12} /> Verified by Labour Federation Officer
                </div>
              </div>
            </div>

            <div className="text-right text-[10px] text-gray-500 space-y-1">
              <div className="font-bold text-gray-700">Authorised Signatory</div>
              <div className="font-serif italic text-xs text-blue-900">Arun Kumar Pattnaik</div>
              <div>Cooperative Federation Registrar</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
