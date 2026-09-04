import { BrowserRouter, Routes, Route, Navigate, useLocation, Link } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LanguageProvider } from './context/LanguageContext';
import { AccessibilityProvider } from './context/AccessibilityContext';
import GovLayout from './layouts/GovLayout';
import PortalLayout from './layouts/PortalLayout';
import AIChatBot from './components/AIChatBot';

// Public Pages (Phase 1-4)
import Home from './pages/Home';
import Services from './pages/Services';
import FindWorker from './pages/FindWorker';
import About from './pages/About';
import Help from './pages/Help';
import Login from './pages/Login';
import Register from './pages/Register';
import RateCard from './pages/RateCard';
import ServiceDetail from './pages/ServiceDetail';

// Federation & Society Lifecycle Pages (Pages 1 - 4)
import SocietyRegistration from './pages/SocietyRegistration';
import SocietyTimeline from './pages/SocietyTimeline';
import FederationPortal from './pages/FederationPortal';
import InstitutionalTenders from './pages/InstitutionalTenders';

// Customer Pages (Phase 5, 9, 10)
import BookService from './pages/BookService';
import CustomerBookings from './pages/CustomerBookings';
import BookingDetail from './pages/BookingDetail';

// Worker Pages (Phase 6)
import WorkerDashboard from './pages/WorkerDashboard';
import WorkerWelfare from './pages/WorkerWelfare';

// Admin Pages (Phase 7, 8)
import AdminDashboard from './pages/AdminDashboard';

// Protected Route Guard Helper with Strict Single-Role Isolation
function ProtectedRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="container py-20 text-center">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-4 border-blue-900 border-t-transparent mb-3"></div>
        <p className="text-sm text-gray-600">Verifying session credentials...</p>
      </div>
    );
  }

  if (!user) {
    const isFederationPath = location.pathname.includes('/federation') || location.pathname.includes('/admin');
    const isWorkerPath = location.pathname.includes('/worker');
    const targetRole = isFederationPath ? 'admin' : isWorkerPath ? 'worker' : 'customer';
    return <Navigate to={`/login?role=${targetRole}`} replace state={{ from: location }} />;
  }

  // Strict Role Isolation: If user's role is not authorized for this route,
  // automatically route them directly to their own dedicated portal!
  if (allowedRoles && !allowedRoles.includes(user.role)) {
    if (user.role === 'WORKER') {
      return <Navigate to="/worker/dashboard" replace />;
    }
    if (user.role === 'COOPERATIVE_ADMIN') {
      return <Navigate to="/admin/dashboard" replace />;
    }
    return <Navigate to="/customer/bookings" replace />;
  }

  return children;
}

function AppRoutes() {
  return (
    <Routes>
      {/* ── 1. Public Marketing & Governance Routes (Wrapped in GovLayout) ── */}
      <Route element={<GovLayout />}>
        <Route path="/" element={<Home />} />
        <Route path="/services" element={<Services />} />
        <Route path="/services/:id" element={<ServiceDetail />} />
        <Route path="/find-worker" element={<FindWorker />} />
        <Route path="/book-service" element={<BookService />} />
        <Route path="/about" element={<About />} />
        <Route path="/help" element={<Help />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        
        {/* Society Statutory Formation Workflow & Timeline (Public) */}
        <Route path="/society/register" element={<SocietyRegistration />} />
        <Route path="/society/timeline" element={<SocietyTimeline />} />
        <Route path="/rate-card" element={<RateCard />} />
      </Route>

      {/* ── 2. Authenticated Dashboard & Portal Routes (Wrapped in PortalLayout) ── */}
      <Route element={<PortalLayout />}>
        {/* Customer Module - Strictly for CUSTOMER only */}
        <Route
          path="/customer/bookings"
          element={
            <ProtectedRoute allowedRoles={['CUSTOMER']}>
              <CustomerBookings />
            </ProtectedRoute>
          }
        />
        <Route
          path="/customer/bookings/:id"
          element={
            <ProtectedRoute allowedRoles={['CUSTOMER']}>
              <BookingDetail />
            </ProtectedRoute>
          }
        />

        {/* Worker Module - Strictly for WORKER only */}
        <Route
          path="/worker/dashboard"
          element={
            <ProtectedRoute allowedRoles={['WORKER']}>
              <WorkerDashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/worker/welfare"
          element={
            <ProtectedRoute allowedRoles={['WORKER']}>
              <WorkerWelfare />
            </ProtectedRoute>
          }
        />

        {/* Federation / Society Admin & Treasurer Portal - Strictly for COOPERATIVE_ADMIN only */}
        <Route
          path="/federation/portal"
          element={
            <ProtectedRoute allowedRoles={['COOPERATIVE_ADMIN']}>
              <FederationPortal />
            </ProtectedRoute>
          }
        />
        <Route
          path="/federation/tenders"
          element={
            <ProtectedRoute allowedRoles={['COOPERATIVE_ADMIN']}>
              <InstitutionalTenders />
            </ProtectedRoute>
          }
        />
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
        <Route path="*" element={<PlaceholderPage title="Page Not Found / पृष्ठ नहीं मिला" desc="The requested cooperative service URL does not exist." />} />
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
            {/* Global Floating AI Assistant (Persists until window closed) */}
            <AIChatBot />
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
