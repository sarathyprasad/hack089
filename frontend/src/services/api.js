const API_BASE = import.meta.env.VITE_API_URL || '/api';

export async function request(endpoint, options = {}) {
  const token = localStorage.getItem('token');
  const headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const config = {
    ...options,
    headers,
  };

  if (config.body && typeof config.body === 'object' && !(config.body instanceof FormData)) {
    config.body = JSON.stringify(config.body);
  }

  const url = API_BASE.endsWith('/') 
    ? `${API_BASE.slice(0, -1)}${endpoint}`
    : `${API_BASE}${endpoint}`;

  const response = await fetch(url, config);
  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    if (response.status === 401 && data.message?.includes('token')) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
    }
    const error = new Error(data.message || data.error || 'Request failed');
    error.status = response.status;
    error.data = data;
    throw error;
  }

  return data;
}

export const api = {
  // Auth
  login: (credentials) => request('/auth/login', { method: 'POST', body: credentials }),
  register: (userData) => request('/auth/register', { method: 'POST', body: userData }),
  getMe: () => request('/auth/me'),

  // Services
  getServices: () => request('/services'),
  getServiceById: (id) => request(`/services/${id}`),

  // Workers
  getWorkers: (params = {}) => {
    const query = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v !== undefined && v !== '' && v !== null)
    ).toString();
    return request(`/workers${query ? `?${query}` : ''}`);
  },
  getWorkerById: (id) => request(`/workers/${id}`),

  // Matching (Phase 3 with Trust Cards & Master Pairing)
  recommendWorkers: (data) => request('/matching/recommend', { method: 'POST', body: data }),

  // Bookings (Phase 1-6)
  createBooking: (data) => request('/bookings', { method: 'POST', body: data }),
  getBookings: (params = {}) => {
    const query = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v !== undefined && v !== '' && v !== null)
    ).toString();
    return request(`/bookings${query ? `?${query}` : ''}`);
  },
  getBookingById: (id) => request(`/bookings/${id}`),
  updateBookingStatus: (id, status, workerId) =>
    request(`/bookings/${id}/status`, { method: 'PUT', body: { status, workerId } }),
  cancelBooking: (id, reason) =>
    request(`/bookings/${id}/cancel`, { method: 'POST', body: { reason } }),

  // Phase 4: OTP Handshakes, Photos & Parts
  verifyArrivalOtp: (bookingId, otp) =>
    request(`/bookings/${bookingId}/verify-arrival-otp`, { method: 'POST', body: { otp } }),
  verifyCompletionOtp: (bookingId, otp) =>
    request(`/bookings/${bookingId}/verify-completion-otp`, { method: 'POST', body: { otp } }),
  uploadPhotoProof: (bookingId, type, photoUrl) =>
    request(`/bookings/${bookingId}/photo-proof`, { method: 'POST', body: { type, photoUrl } }),
  addPartsToBooking: (bookingId, parts) =>
    request(`/bookings/${bookingId}/add-parts`, { method: 'POST', body: { parts } }),

  // Phase 6: 30-Day Guarantee
  claimGuarantee: (bookingId) =>
    request(`/bookings/${bookingId}/claim-guarantee`, { method: 'POST' }),

  // Worker Portal
  getWorkerDashboard: () => request('/worker-portal/dashboard'),
  updateWorkerAvailability: (availability) =>
    request('/worker-portal/availability', { method: 'PUT', body: { availability } }),
  handleWorkerJobAction: (bookingId, action) =>
    request(`/worker-portal/jobs/${bookingId}/action`, { method: 'PUT', body: { action } }),
  getWorkerWelfare: () => request('/worker-portal/welfare'),
  enrollWorkerWelfare: (data) => request('/worker-portal/welfare/enroll', { method: 'POST', body: data }),

  // Admin Portal
  getAdminDashboard: () => request('/admin/dashboard'),
  getAdminWorkers: (params = {}) => {
    const query = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v !== undefined && v !== '' && v !== null)
    ).toString();
    return request(`/admin/workers${query ? `?${query}` : ''}`);
  },
  verifyWorker: (workerId, status, rejectionReason = '') =>
    request(`/admin/workers/${workerId}/verify`, { method: 'PUT', body: { status, rejectionReason } }),
  getAdminBookings: (params = {}) => {
    const query = new URLSearchParams(
      Object.entries(params).filter(([_, v]) => v !== undefined && v !== '' && v !== null)
    ).toString();
    return request(`/admin/bookings${query ? `?${query}` : ''}`);
  },

  // Smart Features & Demand Forecast
  getDemandForecast: () => request('/smart-features/forecast'),
  getWorkforceAllocation: () => request('/smart-features/allocation'),
  approveMutualAid: (proposalId) =>
    request(`/smart-features/mutual-aid/${proposalId}/approve`, { method: 'POST' }),

  // Payments & Invoices
  processPayment: (data) => request('/payments/process', { method: 'POST', body: data }),
  getInvoice: (bookingId) => request(`/payments/invoice/${bookingId}`),

  // Reviews
  submitReview: (data) => request('/reviews', { method: 'POST', body: data }),
  getWorkerReviews: (workerId) => request(`/reviews/worker/${workerId}`),
  getFeaturedReviews: () => request('/reviews/featured'),

  // Phase 4 & 7: Governance, SOS, Disputes & Locked Parts Catalog
  triggerSos: (data) => request('/governance/sos', { method: 'POST', body: data }),
  getSosAlerts: () => request('/governance/sos-alerts'),
  getLiveMap: () => request('/governance/live-map'),
  createDispute: (data) => request('/governance/disputes', { method: 'POST', body: data }),
  getDisputes: () => request('/governance/disputes'),
  resolveDispute: (id, resolutionNotes) =>
    request(`/governance/disputes/${id}/resolve`, { method: 'PUT', body: { resolutionNotes } }),
  getApplianceLineage: (customerId) =>
    request(`/governance/appliance-lineage${customerId ? `/${customerId}` : ''}`),
  getPartsCatalog: (tradeCategory) =>
    request(`/governance/parts-catalog${tradeCategory ? `?tradeCategory=${encodeURIComponent(tradeCategory)}` : ''}`),

  // AI Assistant Chatbot
  sendAIChat: (message, history = [], language = 'EN') =>
    request('/smart-features/ai-chat', {
      method: 'POST',
      body: { message, history, language },
    }),

  // Society Registration & Lifecycle Tracking (Pages 1 & 2)
  registerSociety: (data) =>
    request('/societies/register', {
      method: 'POST',
      body: data,
    }),
  getSocietyTracking: (trackingId) =>
    request(`/societies/track/${encodeURIComponent(trackingId)}`),
  getSocietiesList: (params = {}) => {
    const query = new URLSearchParams(params).toString();
    return request(`/societies${query ? `?${query}` : ''}`);
  },
  updateSocietyTimeline: (id, data) =>
    request(`/societies/${id}/timeline`, {
      method: 'PATCH',
      body: data,
    }),

  // Federation Dual-Console Management (Pages 3 & 4)
  getFederationAdminDashboard: (societyId = 1) =>
    request(`/federation/admin-dashboard?societyId=${societyId}`),
  getFederationTreasurerDashboard: (societyId = 1) =>
    request(`/federation/treasurer-dashboard?societyId=${societyId}`),
  applyNcctTraining: (data) =>
    request('/federation/ncct/apply', {
      method: 'POST',
      body: data,
    }),
  getInstitutionalTenders: () =>
    request('/federation/tenders'),
  registerWorkerByFederation: (data) =>
    request('/federation/workers/register', {
      method: 'POST',
      body: data,
    }),

  // Stats
  getDbStats: () => request('/db/stats'),
};
