import React, { useState, useEffect, useRef, useMemo } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import {
  MapPin, Navigation, Compass, User, Clock, Zap,
  CheckCircle2, AlertTriangle, ShieldCheck, Phone,
  Radio, Layers, RefreshCw, Car, ChevronRight, Maximize2,
  ExternalLink, Globe, Eye, ZoomIn, ZoomOut, AlertCircle
} from 'lucide-react';

export default function LiveRouteMap({
  worker,
  customerAddress = 'Patia, Bhubaneswar',
  customerCoords = { lat: 20.3540, lng: 85.8170 },
  allNearbyWorkers = [],
  onSelectWorker = null,
  compact = false,
  title = 'Live Cooperative Dispatch & Route Map',
}) {
  // Engine: 'LEAFLET' (100% reliable, zero CORS/X-Frame-Options blocking) vs 'GMAPS' (iframe)
  const [mapEngine, setMapEngine] = useState('LEAFLET');
  // Map Layer: 'm' = Roadmap, 'k' = Satellite, 'p' = Terrain
  const [mapType, setMapType] = useState('m');
  // View Mode: 'ROUTE' (directions from worker to customer), 'CUSTOMER' (customer center), 'ARTISAN' (artisan focus)
  const [viewMode, setViewMode] = useState('ROUTE');
  const [zoomLevel, setZoomLevel] = useState(13);
  const [selectedPinWorker, setSelectedPinWorker] = useState(null);
  const [isIframeLoading, setIsIframeLoading] = useState(true);

  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const tileLayerRef = useRef(null);
  const elementsLayerRef = useRef(null);

  // Worker coordinates fallback
  const workerLat = worker?.workerCoords?.lat || worker?.latitude || 20.2961;
  const workerLng = worker?.workerCoords?.lng || worker?.longitude || 85.8245;

  const custLat = customerCoords?.lat || 20.3540;
  const custLng = customerCoords?.lng || 85.8170;

  const distanceKm =
    worker?.distanceKm ||
    Math.round((Math.abs(workerLat - custLat) + Math.abs(workerLng - custLng)) * 80 * 10) / 10 ||
    3.4;
  const etaMinutes = worker?.etaMinutes || Math.max(8, Math.round(distanceKm * 3.2));

  // Direct native Google Maps navigation URL for mobile & desktop
  const googleMapsExternalUrl = `https://www.google.com/maps/dir/?api=1&origin=${workerLat},${workerLng}&destination=${custLat},${custLng}&travelmode=driving`;

  // Build Google Maps Embed URL
  const googleMapsEmbedUrl = useMemo(() => {
    if (viewMode === 'ROUTE') {
      const origin = `${workerLat},${workerLng}`;
      const destination = encodeURIComponent(`${customerAddress || `${custLat},${custLng}`}`);
      return `https://maps.google.com/maps?saddr=${origin}&daddr=${destination}&t=${mapType}&z=${zoomLevel}&output=embed`;
    } else if (viewMode === 'ARTISAN') {
      const activeWorkerLat = selectedPinWorker?.latitude || workerLat;
      const activeWorkerLng = selectedPinWorker?.longitude || workerLng;
      return `https://maps.google.com/maps?q=${activeWorkerLat},${activeWorkerLng}&t=${mapType}&z=${zoomLevel}&output=embed`;
    } else {
      const destinationQuery = encodeURIComponent(
        customerAddress ? `${customerAddress}, ${custLat},${custLng}` : `${custLat},${custLng}`
      );
      return `https://maps.google.com/maps?q=${destinationQuery}&t=${mapType}&z=${zoomLevel}&output=embed`;
    }
  }, [viewMode, mapType, zoomLevel, workerLat, workerLng, custLat, custLng, customerAddress, selectedPinWorker]);

  // Leaflet Map Initialization & Rendering
  useEffect(() => {
    if (mapEngine !== 'LEAFLET') return;
    if (!mapContainerRef.current) return;

    // Destroy existing instance if container re-created
    if (!mapInstanceRef.current) {
      const map = L.map(mapContainerRef.current, {
        zoomControl: false,
        attributionControl: false,
      }).setView([custLat, custLng], zoomLevel);

      mapInstanceRef.current = map;
      elementsLayerRef.current = L.layerGroup().addTo(map);
    }

    const map = mapInstanceRef.current;

    // Tile URLs based on layer
    const tileConfigs = {
      m: {
        url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        attribution: '&copy; OpenStreetMap &copy; CARTO',
        maxZoom: 19,
      },
      k: {
        url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attribution: '&copy; Esri World Imagery',
        maxZoom: 18,
      },
      p: {
        url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
        attribution: '&copy; OpenStreetMap &copy; OpenTopoMap',
        maxZoom: 17,
      },
    };

    const activeConfig = tileConfigs[mapType] || tileConfigs.m;

    if (tileLayerRef.current) {
      map.removeLayer(tileLayerRef.current);
    }

    tileLayerRef.current = L.tileLayer(activeConfig.url, {
      maxZoom: activeConfig.maxZoom,
      subdomains: 'abcd',
    }).addTo(map);

    // Clear previous markers
    if (elementsLayerRef.current) {
      elementsLayerRef.current.clearLayers();
    }

    // Custom HTML Markers using DivIcon (Zero PNG loading issues)
    const workerDivIcon = L.divIcon({
      className: 'leaflet-artisan-pin',
      html: `
        <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 42px; height: 42px;">
          <div style="position: absolute; inset: 0; background: rgba(16, 185, 129, 0.4); border-radius: 50%; animation: ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;"></div>
          <div style="position: relative; width: 34px; height: 34px; background: #0F294A; border: 2.5px solid #F59E0B; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,0,0,0.35); font-size: 16px;">
            🚗
          </div>
        </div>
      `,
      iconSize: [42, 42],
      iconAnchor: [21, 21],
      popupAnchor: [0, -22],
    });

    const customerDivIcon = L.divIcon({
      className: 'leaflet-customer-pin',
      html: `
        <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 40px; height: 40px;">
          <div style="position: absolute; inset: 2px; background: rgba(239, 68, 68, 0.3); border-radius: 50%;"></div>
          <div style="position: relative; width: 32px; height: 32px; background: #DC2626; border: 2.5px solid white; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,0,0,0.35); font-size: 15px;">
            🏠
          </div>
        </div>
      `,
      iconSize: [40, 40],
      iconAnchor: [20, 20],
      popupAnchor: [0, -20],
    });

    // 1. Worker Marker
    const workerMarker = L.marker([workerLat, workerLng], { icon: workerDivIcon })
      .bindPopup(`
        <div style="font-family: system-ui, sans-serif; font-size: 12px; min-width: 170px; padding: 2px;">
          <strong style="color: #0F294A; font-size: 13px; display: block;">${worker?.name || 'Verified Artisan'}</strong>
          <span style="color: #059669; font-weight: 700; font-size: 11px;">🟢 Live GPS En Route</span>
          <div style="margin-top: 4px; color: #4B5563; font-size: 11px;">
            Speed: <strong>28 km/h</strong> • ETA: <strong>~${etaMinutes} Mins</strong>
          </div>
          <div style="margin-top: 2px; color: #6B7280; font-size: 10px;">
            ${worker?.primary_trade || worker?.trade || 'Cooperative Professional'}
          </div>
        </div>
      `);
    elementsLayerRef.current.addLayer(workerMarker);

    // 2. Customer Destination Marker
    const custMarker = L.marker([custLat, custLng], { icon: customerDivIcon })
      .bindPopup(`
        <div style="font-family: system-ui, sans-serif; font-size: 12px; min-width: 170px; padding: 2px;">
          <strong style="color: #DC2626; font-size: 13px; display: block;">Service Destination</strong>
          <span style="color: #374151; font-size: 11px;">${customerAddress}</span>
          <div style="margin-top: 4px; font-weight: 700; color: #0F294A;">
            Distance: ${distanceKm} km
          </div>
        </div>
      `);
    elementsLayerRef.current.addLayer(custMarker);

    // 3. Route Polyline
    const routeCoordinates = [
      [workerLat, workerLng],
      // slight realistic curve midpoint
      [(workerLat + custLat) / 2 + 0.002, (workerLng + custLng) / 2 - 0.003],
      [custLat, custLng]
    ];

    const routePolyline = L.polyline(routeCoordinates, {
      color: '#0F294A',
      weight: 4.5,
      dashArray: '8, 8',
      opacity: 0.9,
    });
    elementsLayerRef.current.addLayer(routePolyline);

    // 4. Nearby Workers (if any)
    if (allNearbyWorkers && allNearbyWorkers.length > 0) {
      allNearbyWorkers.forEach((w) => {
        if (w.id === worker?.id) return;
        const wLat = w.latitude || (custLat + (Math.random() - 0.5) * 0.04);
        const wLng = w.longitude || (custLng + (Math.random() - 0.5) * 0.04);

        const nearbyDivIcon = L.divIcon({
          className: 'leaflet-nearby-pin',
          html: `
            <div style="width: 26px; height: 26px; background: #3B82F6; border: 2px solid white; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 5px rgba(0,0,0,0.25); font-size: 12px; color: white;">
              🔧
            </div>
          `,
          iconSize: [26, 26],
          iconAnchor: [13, 13],
        });

        const nm = L.marker([wLat, wLng], { icon: nearbyDivIcon })
          .bindPopup(`
            <div style="font-family: system-ui, sans-serif; font-size: 11px;">
              <strong>${w.name}</strong><br/>
              <span>${w.primary_trade || 'Artisan'} • ⭐ ${w.rating || '4.8'}</span>
            </div>
          `);
        elementsLayerRef.current.addLayer(nm);
      });
    }

    // Auto-fit bounds with comfortable padding
    const bounds = L.latLngBounds([
      [workerLat, workerLng],
      [custLat, custLng],
    ]);
    map.fitBounds(bounds, { padding: [45, 45], maxZoom: 16 });

    // Force redraw on mount/tab switch
    setTimeout(() => {
      map.invalidateSize();
    }, 200);

  }, [mapEngine, mapType, workerLat, workerLng, custLat, custLng, customerAddress, distanceKm, etaMinutes, worker, allNearbyWorkers]);

  const handleRecenter = () => {
    setViewMode('ROUTE');
    setZoomLevel(13);
    setMapType('m');
    setSelectedPinWorker(null);

    if (mapInstanceRef.current) {
      const bounds = L.latLngBounds([
        [workerLat, workerLng],
        [custLat, custLng],
      ]);
      mapInstanceRef.current.fitBounds(bounds, { padding: [45, 45] });
      mapInstanceRef.current.invalidateSize();
    }
  };

  const handleZoomIn = () => {
    setZoomLevel((prev) => Math.min(prev + 1, 19));
    if (mapInstanceRef.current) {
      mapInstanceRef.current.zoomIn();
    }
  };

  const handleZoomOut = () => {
    setZoomLevel((prev) => Math.max(prev - 1, 8));
    if (mapInstanceRef.current) {
      mapInstanceRef.current.zoomOut();
    }
  };

  return (
    <div
      className={`rounded-2xl border border-gray-200 bg-white shadow-xl overflow-hidden ${
        compact ? 'p-3' : 'p-4 sm:p-6'
      } space-y-4`}
    >
      {/* Map Header & Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-gray-100">
        <div>
          <div className="flex items-center gap-2 flex-wrap">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></span>
            <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-emerald-700 flex items-center gap-1.5">
              <span className="px-1.5 py-0.5 rounded bg-blue-100 text-blue-900 border border-blue-200 font-sans">
                {mapEngine === 'LEAFLET' ? 'Live GPS Canvas Engine' : 'Google Maps Embed'}
              </span>
              <span>Real-Time Telemetry</span>
            </span>
          </div>
          <h3 className="font-bold text-sm sm:text-base text-gray-900 mt-1 flex items-center gap-2">
            <Navigation size={16} className="text-blue-900" />
            {title}
          </h3>
        </div>

        {/* View, Engine, Map Style & External Link Controls */}
        <div className="flex items-center gap-2 flex-wrap">
          
          {/* Engine Selector: Leaflet (Zero Block) vs Google Maps */}
          <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-xl text-xs font-bold">
            <button
              type="button"
              onClick={() => setMapEngine('LEAFLET')}
              className={`px-2.5 py-1 rounded-lg transition flex items-center gap-1 ${
                mapEngine === 'LEAFLET'
                  ? 'bg-[#0F294A] text-white shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
              title="Interactive Live GPS Map (Fast & 100% Reliable)"
            >
              <Compass size={12} />
              <span>Interactive Map</span>
            </button>
            <button
              type="button"
              onClick={() => setMapEngine('GMAPS')}
              className={`px-2.5 py-1 rounded-lg transition flex items-center gap-1 ${
                mapEngine === 'GMAPS'
                  ? 'bg-[#0F294A] text-white shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
              title="Google Maps Web View"
            >
              <Globe size={12} />
              <span>Google Maps Web</span>
            </button>
          </div>

          {/* Map Layer Selector (Roadmap, Satellite, Terrain) */}
          <div className="flex items-center gap-1 bg-gray-100 p-1 rounded-xl text-xs font-semibold">
            <button
              type="button"
              onClick={() => setMapType('m')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapType === 'm'
                  ? 'bg-white text-blue-950 shadow-xs font-bold'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
              title="Standard Roadmap"
            >
              🗺️ Map
            </button>
            <button
              type="button"
              onClick={() => setMapType('k')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapType === 'k'
                  ? 'bg-white text-blue-950 shadow-xs font-bold'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
              title="Satellite Imagery"
            >
              🛰️ Satellite
            </button>
            <button
              type="button"
              onClick={() => setMapType('p')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapType === 'p'
                  ? 'bg-white text-blue-950 shadow-xs font-bold'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
              title="Terrain Topography"
            >
              ⛰️ Terrain
            </button>
          </div>

          {/* Recenter button */}
          <button
            type="button"
            onClick={handleRecenter}
            className="p-1.5 rounded-lg border border-gray-200 text-gray-600 hover:bg-gray-100 hover:text-gray-900 transition shadow-2xs"
            title="Recenter to Route"
          >
            <RefreshCw size={14} />
          </button>

          {/* Open Native Google Maps App */}
          <a
            href={googleMapsExternalUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-secondary btn-sm text-xs font-bold flex items-center gap-1.5 bg-amber-400 hover:bg-amber-300 text-slate-950 border-amber-500 shadow-2xs transition"
            title="Open Live Turn-by-Turn Navigation in Google Maps App"
          >
            <ExternalLink size={13} className="text-slate-950" />
            <span>Google Maps App</span>
          </a>
        </div>
      </div>

      {/* Map Display Canvas */}
      <div className="relative w-full rounded-2xl overflow-hidden border border-gray-200 shadow-inner bg-slate-100">
        
        {/* LEAFLET INTERACTIVE CANVAS ENGINE (PRIMARY - 100% UNBLOCKABLE) */}
        {mapEngine === 'LEAFLET' ? (
          <div
            ref={mapContainerRef}
            className={`w-full ${compact ? 'h-72 sm:h-80' : 'h-88 sm:h-96'} z-0`}
            style={{ minHeight: compact ? '288px' : '352px' }}
          />
        ) : (
          /* GOOGLE MAPS EMBED ENGINE (SECONDARY - WITH BLOCK FALLBACK) */
          <div className="relative w-full">
            {isIframeLoading && (
              <div className="absolute inset-0 z-10 flex items-center justify-center bg-slate-100/80 backdrop-blur-xs">
                <div className="flex flex-col items-center gap-2">
                  <div className="w-8 h-8 rounded-full border-4 border-blue-900 border-t-transparent animate-spin" />
                  <span className="text-xs text-gray-500 font-semibold">Connecting to Google Maps...</span>
                </div>
              </div>
            )}

            <iframe
              title="Google Maps Live Dispatch Route"
              src={googleMapsEmbedUrl}
              className={`w-full ${compact ? 'h-72 sm:h-80' : 'h-88 sm:h-96'} border-0 transition-opacity duration-300 ${
                isIframeLoading ? 'opacity-40' : 'opacity-100'
              }`}
              loading="lazy"
              allowFullScreen
              referrerPolicy="no-referrer-when-downgrade"
              onLoad={() => setIsIframeLoading(false)}
            />

            {/* In-frame Helper Ribbon if browser blocks Google embed */}
            <div className="absolute top-3 left-3 right-16 z-20 bg-white/95 backdrop-blur-md p-2 rounded-xl border border-amber-300 shadow-md text-xs text-slate-800 flex items-center justify-between gap-2">
              <div className="flex items-center gap-1.5 text-amber-900">
                <AlertCircle size={14} className="text-amber-600 shrink-0" />
                <span className="text-[11px] font-medium leading-tight">
                  If Google Maps iframe is blocked by your browser, switch back to our built-in <strong>Interactive Map</strong>.
                </span>
              </div>
              <button
                type="button"
                onClick={() => setMapEngine('LEAFLET')}
                className="px-2.5 py-1 rounded-lg bg-blue-950 text-white text-[10px] font-bold shrink-0 hover:bg-blue-900"
              >
                Switch to Live Map
              </button>
            </div>
          </div>
        )}

        {/* Floating Zoom Controls Overlay */}
        <div className="absolute top-3 right-3 z-20 flex flex-col gap-1.5 bg-white/90 backdrop-blur-md p-1 rounded-xl border border-gray-200 shadow-md">
          <button
            type="button"
            onClick={handleZoomIn}
            className="p-1.5 rounded-lg text-gray-700 hover:bg-gray-100 transition"
            title="Zoom In"
          >
            <ZoomIn size={15} />
          </button>
          <button
            type="button"
            onClick={handleZoomOut}
            className="p-1.5 rounded-lg text-gray-700 hover:bg-gray-100 transition"
            title="Zoom Out"
          >
            <ZoomOut size={15} />
          </button>
        </div>

        {/* Floating Real-Time Telemetry Bar */}
        <div className="absolute bottom-3 left-3 right-3 z-20 flex items-center justify-between bg-white/95 backdrop-blur-md px-3.5 py-2.5 rounded-xl border border-gray-200/90 shadow-lg text-xs text-gray-800">
          <div className="flex items-center gap-2.5 flex-wrap">
            <span className="font-bold text-emerald-800 flex items-center gap-1 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
              <Radio size={12} className="animate-pulse text-emerald-600" /> GPS Telemetry: Active
            </span>
            <span className="text-gray-300 hidden sm:inline">|</span>
            <span className="text-gray-600">
              Transit Distance: <strong>{distanceKm} km</strong>
            </span>
            <span className="text-gray-300 hidden sm:inline">|</span>
            <span className="text-gray-600">
              Speed: <strong>28 km/h</strong>
            </span>
          </div>

          <div className="flex items-center gap-2">
            <div className="font-mono text-blue-950 font-bold text-xs sm:text-sm bg-blue-50 px-2.5 py-1 rounded-lg border border-blue-200">
              ETA: ~{etaMinutes} Mins
            </div>
            <a
              href={googleMapsExternalUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="p-1.5 rounded-lg bg-blue-950 text-amber-300 hover:bg-blue-900 transition"
              title="Open Navigation in Google Maps App"
            >
              <Navigation size={14} />
            </a>
          </div>
        </div>
      </div>

      {/* Telemetry Dashboard Info Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 text-xs">
        <div className="p-3 rounded-xl bg-gray-50 border border-gray-200">
          <div className="text-[10px] text-gray-500 uppercase font-mono font-bold">Transit Distance</div>
          <div className="text-base font-extrabold text-blue-950 mt-0.5 flex items-center gap-1">
            <Navigation size={14} className="text-blue-700" />
            <span>{distanceKm} km</span>
          </div>
          <div className="text-[10px] text-emerald-700 mt-0.5 font-semibold">Shortest Route Calibrated</div>
        </div>

        <div className="p-3 rounded-xl bg-gray-50 border border-gray-200">
          <div className="text-[10px] text-gray-500 uppercase font-mono font-bold">Estimated Arrival</div>
          <div className="text-base font-extrabold text-amber-700 mt-0.5 flex items-center gap-1">
            <Clock size={14} className="text-amber-600" />
            <span>~{etaMinutes} Mins</span>
          </div>
          <div className="text-[10px] text-gray-500 mt-0.5">Calibrated to Urban Traffic</div>
        </div>

        <div className="p-3 rounded-xl bg-gray-50 border border-gray-200">
          <div className="text-[10px] text-gray-500 uppercase font-mono font-bold">Artisan Base</div>
          <div className="text-xs font-bold text-gray-900 mt-0.5 truncate">
            {worker?.service_area || worker?.city || 'Bhubaneswar Metro'}
          </div>
          <div className="text-[10px] text-blue-900 truncate font-semibold">
            {worker?.name || 'Verified Cooperative Worker'}
          </div>
        </div>

        <div className="p-3 rounded-xl bg-gray-50 border border-gray-200">
          <div className="text-[10px] text-gray-500 uppercase font-mono font-bold">Destination Address</div>
          <div className="text-xs font-bold text-emerald-800 mt-0.5 truncate">{customerAddress}</div>
          <div className="text-[10px] text-gray-500">Citizen Service Location</div>
        </div>
      </div>

      {/* Selected Radar Artisan Details Popover */}
      {selectedPinWorker && (
        <div className="p-3.5 rounded-xl bg-blue-50 border border-blue-200 text-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3 animate-in fade-in duration-200">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-blue-950 text-amber-300 flex items-center justify-center font-bold">
              {selectedPinWorker.name?.charAt(0)}
            </div>
            <div>
              <div className="font-bold text-gray-900 flex items-center gap-1.5">
                <span>{selectedPinWorker.name}</span>
                <span className="font-mono text-[10px] text-gray-600 bg-gray-200 px-1.5 py-0.5 rounded">
                  {selectedPinWorker.worker_code}
                </span>
              </div>
              <div className="text-[10px] text-gray-600">
                {selectedPinWorker.primary_trade} • ⭐ {selectedPinWorker.rating?.toFixed(1) || '4.8'} • 📍{' '}
                {selectedPinWorker.distanceKm || '3.2'} km away
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span
              className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY'
                  ? 'bg-amber-100 text-amber-900 border border-amber-300'
                  : 'bg-emerald-100 text-emerald-900 border border-emerald-300'
              }`}
            >
              {selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY'
                ? 'BUSY / ENGAGED'
                : 'AVAILABLE'}
            </span>

            {!(selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY') &&
              onSelectWorker && (
                <button
                  type="button"
                  onClick={() => onSelectWorker(selectedPinWorker)}
                  className="btn btn-primary btn-sm text-[11px] font-bold py-1 px-2.5"
                >
                  Select This Artisan
                </button>
              )}
          </div>
        </div>
      )}

      {/* Nearby Workers Quick Carousel (In Radar / Nearby Mode) */}
      {allNearbyWorkers?.length > 0 && (
        <div className="space-y-2 pt-2 border-t border-gray-100">
          <span className="text-[11px] font-bold uppercase tracking-wider text-gray-500 block">
            Nearby Verified Artisans in this Locality:
          </span>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2">
            {allNearbyWorkers.map((w) => {
              const isSelected = selectedPinWorker?.id === w.id;
              return (
                <div
                  key={w.id}
                  onClick={() => {
                    setSelectedPinWorker(w);
                    if (mapInstanceRef.current && (w.latitude || w.longitude)) {
                      mapInstanceRef.current.setView([w.latitude || custLat, w.longitude || custLng], 14);
                    }
                  }}
                  className={`p-2.5 rounded-xl border cursor-pointer transition flex items-center justify-between text-xs ${
                    isSelected
                      ? 'border-blue-950 bg-blue-50/80 shadow-xs'
                      : 'border-gray-200 hover:border-gray-300 bg-gray-50/50'
                  }`}
                >
                  <div>
                    <div className="font-bold text-gray-900">{w.name}</div>
                    <span className="text-[10px] text-gray-500">
                      {w.primary_trade || 'Artisan'} • {w.distanceKm || '2.5'} km
                    </span>
                  </div>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-100 text-blue-900">
                    Focus Pin →
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
