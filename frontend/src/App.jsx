import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LanguageProvider } from './context/LanguageContext';
import { AccessibilityProvider } from './context/AccessibilityContext';
import GovLayout from './layouts/GovLayout';
import PortalLayout from './layouts/PortalLayout';

// Public Pages (Phase 1-4)
import Home from './pages/Home';
import Services from './pages/Services';
import FindWorker from './pages/FindWorker';
import About from './pages/About';
import Help from './pages/Help';
import Login from './pages/Login';
import Register from './pages/Register';

// Customer Pages (Phase 5, 9, 10)
import BookService from './pages/BookService';
import CustomerBookings from './pages/CustomerBookings';
import BookingDetail from './pages/BookingDetail';

// Worker Pages (Phase 6)
import WorkerDashboard from './pages/WorkerDashboard';
import WorkerWelfare from './pages/WorkerWelfare';

// Admin Pages (Phase 7, 8)
import AdminDashboard from './pages/AdminDashboard';

// Protected Route Guard Helper
function ProtectedRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="container py-20 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
        <p className="text-sm text-gray-600">Verifying session credentials...</p>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return (
      <div className="container py-16 text-center max-w-md mx-auto">
        <div className="bg-red-50 p-6 rounded-xl border border-red-200">
          <h2 className="text-lg font-bold text-red-900 mb-2">Access Restricted</h2>
          <p className="text-xs text-red-700 mb-4">
            This module requires <strong>{allowedRoles.join(' / ')}</strong> authorization.
          </p>
          <a href="/" className="btn btn-primary btn-sm">Return to Home</a>
        </div>
      </div>
    );
  }

  return children;
}

function AppRoutes() {
  return (
    <Routes>
      {/* ── 1. Public Marketing Routes (Wrapped in GovLayout) ── */}
      <Route element={<GovLayout />}>
        <Route path="/" element={<Home />} />
        <Route path="/services" element={<Services />} />
        <Route path="/find-worker" element={<FindWorker />} />
        <Route path="/book-service" element={<BookService />} />
        <Route path="/about" element={<About />} />
        <Route path="/help" element={<Help />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
      </Route>

      {/* ── 2. Authenticated Dashboard & Portal Routes (Wrapped in PortalLayout) ── */}
      <Route element={<PortalLayout />}>
        {/* Customer Module */}
        <Route
          path="/customer/bookings"
          element={
            <ProtectedRoute allowedRoles={['CUSTOMER', 'WORKER', 'COOPERATIVE_ADMIN']}>
              <CustomerBookings />
            </ProtectedRoute>
          }
        />
        <Route
          path="/customer/bookings/:id"
          element={
            <ProtectedRoute allowedRoles={['CUSTOMER', 'WORKER', 'COOPERATIVE_ADMIN']}>
              <BookingDetail />
            </ProtectedRoute>
          }
        />

        {/* Worker Module */}
        <Route
          path="/worker/dashboard"
          element={
            <ProtectedRoute allowedRoles={['WORKER', 'COOPERATIVE_ADMIN']}>
              <WorkerDashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/worker/welfare"
          element={
            <ProtectedRoute allowedRoles={['WORKER', 'COOPERATIVE_ADMIN']}>
              <WorkerWelfare />
            </ProtectedRoute>
          }
        />

        {/* Admin Module */}
        <Route
          path="/admin/dashboard"
          element={
            <ProtectedRoute allowedRoles={['COOPERATIVE_ADMIN']}>
              <AdminDashboard />
            </ProtectedRoute>
          }
        />
      </Route>

      {/* 404 Fallback in GovLayout */}
      <Route element={<GovLayout />}>
        <Route path="*" element={<PlaceholderPage title="Page Not Found / पृष्ठ नहीं मिला" desc="The requested government service URL does not exist." />} />
      </Route>
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <LanguageProvider>
        <AccessibilityProvider>
          <AuthProvider>
            <AppRoutes />
          </AuthProvider>
        </AccessibilityProvider>
      </LanguageProvider>
    </BrowserRouter>
  );
}

function PlaceholderPage({ title, step, desc }) {
  return (
    <div className="container py-16 text-center max-w-xl mx-auto">
      <div className="bg-white p-8 rounded-xl border border-gray-200 shadow-xs">
        {step && (
          <span className="inline-block px-2.5 py-0.5 rounded bg-blue-100 text-blue-900 text-xs font-bold uppercase tracking-wider mb-3">
            Upcoming: {step}
          </span>
        )}
        <h1 className="text-2xl font-bold text-blue-950 mb-2">{title}</h1>
        <p className="text-sm text-gray-600 mb-6">{desc}</p>
        <div className="flex justify-center gap-3">
          <a href="/" className="btn btn-secondary btn-sm">Home</a>
          <a href="/services" className="btn btn-primary btn-sm">Browse Services</a>
        </div>
      </div>
    </div>
  );
}
