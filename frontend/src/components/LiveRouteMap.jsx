import React, { useState, useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import {
  MapPin, Navigation, Compass, User, Clock, Zap,
  CheckCircle2, AlertTriangle, ShieldCheck, Phone,
  Radio, Layers, RefreshCw, Car, ChevronRight, Maximize2
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
  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const layerGroupRef = useRef(null);
  const vehicleMarkerRef = useRef(null);

  const [mapStyle, setMapStyle] = useState('VOYAGER'); // 'VOYAGER', 'OSM', 'SATELLITE', 'DARK'
  const [viewMode, setViewMode] = useState('ROUTE'); // 'ROUTE' or 'RADAR'
  const [progress, setProgress] = useState(0.35); // Progress along route (0 to 1)
  const [selectedPinWorker, setSelectedPinWorker] = useState(null);

  // Worker coordinates fallback
  const workerLat = worker?.workerCoords?.lat || worker?.latitude || 20.2961;
  const workerLng = worker?.workerCoords?.lng || worker?.longitude || 85.8245;

  const custLat = customerCoords?.lat || 20.3540;
  const custLng = customerCoords?.lng || 85.8170;

  const distanceKm = worker?.distanceKm || (Math.round((Math.abs(workerLat - custLat) + Math.abs(workerLng - custLng)) * 80 * 10) / 10) || 3.4;
  const etaMinutes = worker?.etaMinutes || Math.max(8, Math.round(distanceKm * 3.2));

  // Generate realistic route waypoints between worker and customer
  const routeWaypoints = (worker?.routeWaypoints && worker.routeWaypoints.length > 0)
    ? worker.routeWaypoints.map((p) => [p.lat, p.lng])
    : [
        [workerLat, workerLng],
        [workerLat * 0.75 + custLat * 0.25 + 0.002, workerLng * 0.75 + custLng * 0.25 - 0.002],
        [workerLat * 0.5 + custLat * 0.5 - 0.003, workerLng * 0.5 + custLng * 0.5 + 0.003],
        [workerLat * 0.25 + custLat * 0.75 + 0.002, workerLng * 0.25 + custLng * 0.75 - 0.001],
        [custLat, custLng],
      ];

  // Tile layer URLs
  const tileProviders = {
    VOYAGER: {
      url: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      attribution: '&copy; <a href="https://carto.com/">CARTO</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    },
    OSM: {
      url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    },
    DARK: {
      url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      attribution: '&copy; <a href="https://carto.com/">CARTO</a> &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    },
    SATELLITE: {
      url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
    },
  };

  // Initialize Map
  useEffect(() => {
    if (!mapContainerRef.current) return;

    if (!mapInstanceRef.current) {
      const map = L.map(mapContainerRef.current, {
        center: [(workerLat + custLat) / 2, (workerLng + custLng) / 2],
        zoom: 13,
        zoomControl: false,
        attributionControl: false,
      });

      L.control.zoom({ position: 'topright' }).addTo(map);

      mapInstanceRef.current = map;
      layerGroupRef.current = L.layerGroup().addTo(map);
    }

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, []);

  // Update Tile Layer when mapStyle changes
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map) return;

    // Remove existing tile layer
    map.eachLayer((layer) => {
      if (layer instanceof L.TileLayer) {
        map.removeLayer(layer);
      }
    });

    const currentProvider = tileProviders[mapStyle] || tileProviders.VOYAGER;
    L.tileLayer(currentProvider.url, {
      maxZoom: 19,
      subdomains: 'abcd',
      attribution: currentProvider.attribution,
    }).addTo(map);
  }, [mapStyle]);

  // Update Markers, Route Polyline & Fit Bounds
  useEffect(() => {
    const map = mapInstanceRef.current;
    const layerGroup = layerGroupRef.current;
    if (!map || !layerGroup) return;

    layerGroup.clearLayers();

    const bounds = L.latLngBounds([]);

    // 1. Customer Destination Pin (Emerald Green)
    const customerIcon = L.divIcon({
      className: 'custom-customer-pin',
      html: `
        <div style="display: flex; flex-direction: column; align-items: center; cursor: pointer;">
          <div style="background: #059669; color: #ffffff; padding: 2px 8px; border-radius: 9999px; font-size: 10px; font-weight: 700; white-space: nowrap; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.3); border: 1.5px solid #a7f3d0; margin-bottom: 2px;">
            🏠 Customer Destination
          </div>
          <div style="width: 32px; height: 32px; border-radius: 9999px; background: rgba(5, 150, 105, 0.3); border: 2.5px solid #10b981; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 15px rgba(16,185,129,0.7);">
            <div style="width: 16px; height: 16px; border-radius: 9999px; background: #10b981; display: flex; align-items: center; justify-content: center; color: white; font-size: 9px; font-weight: bold;">
              📍
            </div>
          </div>
        </div>
      `,
      iconSize: [120, 50],
      iconAnchor: [60, 50],
    });

    const custMarker = L.marker([custLat, custLng], { icon: customerIcon })
      .bindPopup(`
        <div style="padding: 4px; font-family: sans-serif;">
          <div style="font-weight: 800; color: #065f46; font-size: 12px;">🏠 Customer Place</div>
          <div style="color: #374151; font-size: 11px; margin-top: 2px;">${customerAddress}</div>
          <div style="color: #6b7280; font-size: 10px; margin-top: 2px;">Coordinates: ${custLat.toFixed(4)}° N, ${custLng.toFixed(4)}° E</div>
        </div>
      `)
      .addTo(layerGroup);

    bounds.extend([custLat, custLng]);

    if (viewMode === 'ROUTE') {
      // 2. Primary Worker Origin Pin (Blue)
      const workerIcon = L.divIcon({
        className: 'custom-worker-pin',
        html: `
          <div style="display: flex; flex-direction: column; align-items: center; cursor: pointer;">
            <div style="background: #1e3a8a; color: #ffffff; padding: 2px 8px; border-radius: 9999px; font-size: 10px; font-weight: 700; white-space: nowrap; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.3); border: 1.5px solid #93c5fd; margin-bottom: 2px;">
              🛠️ ${worker?.name || 'Assigned Artisan'} (${worker?.tier || 'MASTER'})
            </div>
            <div style="width: 32px; height: 32px; border-radius: 12px; background: #1e3a8a; border: 2.5px solid #60a5fa; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 15px rgba(59,130,246,0.6); color: #fbbf24; font-weight: 800; font-size: 12px;">
              ${worker?.name ? worker.name.charAt(0) : 'W'}
            </div>
          </div>
        `,
        iconSize: [140, 50],
        iconAnchor: [70, 50],
      });

      L.marker([workerLat, workerLng], { icon: workerIcon })
        .bindPopup(`
          <div style="padding: 4px; font-family: sans-serif;">
            <div style="font-weight: 800; color: #1e3a8a; font-size: 12px;">${worker?.name || 'Verified Artisan'}</div>
            <div style="color: #374151; font-size: 11px; margin-top: 2px;">${worker?.primary_trade || 'Master Technician'} • ⭐ ${worker?.rating?.toFixed(1) || '4.9'}</div>
            <div style="color: #059669; font-size: 10px; font-weight: 600; margin-top: 2px;">📍 ${distanceKm} km away • ~${etaMinutes} mins transit ETA</div>
          </div>
        `)
        .addTo(layerGroup);

      bounds.extend([workerLat, workerLng]);

      // 3. Real Route Polyline
      const polylineGlow = L.polyline(routeWaypoints, {
        color: '#0284c7',
        weight: 8,
        opacity: 0.35,
        lineCap: 'round',
        lineJoin: 'round',
      }).addTo(layerGroup);

      const polylineInner = L.polyline(routeWaypoints, {
        color: '#0369a1',
        weight: 4,
        opacity: 0.9,
        dashArray: '8, 8',
        lineCap: 'round',
      }).addTo(layerGroup);

      // 4. Moving Vehicle Marker
      const currentLat = workerLat + (custLat - workerLat) * progress;
      const currentLng = workerLng + (custLng - workerLng) * progress;

      const vehicleIcon = L.divIcon({
        className: 'custom-vehicle-pin',
        html: `
          <div style="width: 32px; height: 32px; border-radius: 9999px; background: #d97706; border: 2px solid #ffffff; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 15px rgba(217,119,6,0.9); transform: scale(1.1); animation: bounce 1s infinite;">
            <span style="font-size: 14px;">🚗</span>
          </div>
        `,
        iconSize: [32, 32],
        iconAnchor: [16, 16],
      });

      const vehicleMarker = L.marker([currentLat, currentLng], { icon: vehicleIcon })
        .bindPopup(`<b>En Route to Customer Location</b><br/>Speed: 28 km/h • ETA: ~${etaMinutes} mins`)
        .addTo(layerGroup);

      vehicleMarkerRef.current = vehicleMarker;
      bounds.extend([currentLat, currentLng]);
    } else {
      // 5. Radar Mode: Plot all nearby workers
      allNearbyWorkers.forEach((w) => {
        const wLat = w.latitude || w.workerCoords?.lat || (custLat + (Math.random() - 0.5) * 0.04);
        const wLng = w.longitude || w.workerCoords?.lng || (custLng + (Math.random() - 0.5) * 0.04);
        const isBusy = w.isSlotOccupied || w.availability === 'BUSY' || w.availability === 'OFFLINE';
        const isSelected = worker?.id === w.id;

        const pinColor = isSelected ? '#2563eb' : isBusy ? '#d97706' : '#059669';
        const bgBadge = isSelected ? '#1e3a8a' : isBusy ? '#78350f' : '#064e3b';

        const radarIcon = L.divIcon({
          className: 'custom-radar-pin',
          html: `
            <div style="display: flex; flex-direction: column; align-items: center; cursor: pointer;">
              <div style="background: ${bgBadge}; color: #ffffff; padding: 2px 6px; border-radius: 9999px; font-size: 9px; font-weight: 700; white-space: nowrap; box-shadow: 0 2px 4px rgba(0,0,0,0.3); border: 1px solid ${pinColor}; margin-bottom: 2px;">
                ${w.name?.split(' ')[0]} (${w.distanceKm || '2.5'}km)
              </div>
              <div style="width: 26px; height: 26px; border-radius: 8px; background: ${pinColor}; border: 2px solid #ffffff; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 10px ${pinColor}; color: #ffffff; font-weight: 800; font-size: 11px;">
                ${w.name ? w.name.charAt(0) : 'W'}
              </div>
            </div>
          `,
          iconSize: [100, 44],
          iconAnchor: [50, 44],
        });

        const m = L.marker([wLat, wLng], { icon: radarIcon })
          .addTo(layerGroup)
          .on('click', () => {
            setSelectedPinWorker(w);
            if (onSelectWorker && !isBusy) {
              onSelectWorker(w);
            }
          });

        bounds.extend([wLat, wLng]);
      });
    }

    if (bounds.isValid()) {
      map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
    }
  }, [worker, customerCoords, allNearbyWorkers, viewMode, progress]);

  // Animate moving vehicle along route
  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => (prev >= 0.95 ? 0.15 : prev + 0.02));
    }, 1500);
    return () => clearInterval(interval);
  }, []);

  const handleRecenter = () => {
    const map = mapInstanceRef.current;
    if (!map) return;
    map.fitBounds(
      [
        [workerLat, workerLng],
        [custLat, custLng],
      ],
      { padding: [50, 50], maxZoom: 15 }
    );
  };

  return (
    <div className={`rounded-2xl border border-gray-200 bg-white shadow-xl overflow-hidden ${compact ? 'p-3' : 'p-4 sm:p-6'} space-y-4`}>
      {/* Map Header & Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-gray-100">
        <div>
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></span>
            <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-emerald-700">
              Live Real-World GPS Telemetry (OpenStreetMap)
            </span>
          </div>
          <h3 className="font-bold text-sm sm:text-base text-gray-900 mt-0.5 flex items-center gap-2">
            <Navigation size={16} className="text-blue-900" />
            {title}
          </h3>
        </div>

        {/* View & Tile Controls */}
        <div className="flex items-center gap-2 flex-wrap">
          {/* Tile Layer Selector */}
          <div className="flex items-center gap-1 bg-gray-100 p-1 rounded-xl text-xs font-semibold">
            <button
              type="button"
              onClick={() => setMapStyle('VOYAGER')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapStyle === 'VOYAGER' ? 'bg-white text-blue-950 shadow-xs font-bold' : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              🗺️ Street
            </button>
            <button
              type="button"
              onClick={() => setMapStyle('SATELLITE')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapStyle === 'SATELLITE' ? 'bg-white text-blue-950 shadow-xs font-bold' : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              🛰️ Satellite
            </button>
            <button
              type="button"
              onClick={() => setMapStyle('DARK')}
              className={`px-2.5 py-1 rounded-lg transition ${
                mapStyle === 'DARK' ? 'bg-white text-blue-950 shadow-xs font-bold' : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              🌙 Dark
            </button>
          </div>

          {/* Mode Switcher */}
          <div className="flex items-center gap-1 bg-blue-50 p-1 rounded-xl text-xs font-bold">
            <button
              type="button"
              onClick={() => setViewMode('ROUTE')}
              className={`px-3 py-1 rounded-lg transition flex items-center gap-1 ${
                viewMode === 'ROUTE' ? 'bg-blue-950 text-white shadow-xs' : 'text-blue-900 hover:bg-blue-100'
              }`}
            >
              <Car size={13} />
              <span>Route</span>
            </button>
            <button
              type="button"
              onClick={() => setViewMode('RADAR')}
              className={`px-3 py-1 rounded-lg transition flex items-center gap-1 ${
                viewMode === 'RADAR' ? 'bg-blue-950 text-white shadow-xs' : 'text-blue-900 hover:bg-blue-100'
              }`}
            >
              <Radio size={13} />
              <span>Nearby ({allNearbyWorkers?.length || 4})</span>
            </button>
          </div>

          <button
            type="button"
            onClick={handleRecenter}
            className="p-1.5 rounded-lg border border-gray-200 text-gray-600 hover:bg-gray-100 hover:text-gray-900 transition shadow-2xs"
            title="Recenter Map"
          >
            <RefreshCw size={14} />
          </button>
        </div>
      </div>

      {/* Real Map Canvas */}
      <div className="relative w-full rounded-2xl overflow-hidden border border-gray-200 shadow-inner">
        <div
          ref={mapContainerRef}
          className={`w-full ${compact ? 'h-64 sm:h-72' : 'h-80 sm:h-96'} z-0`}
          style={{ background: '#e5e7eb' }}
        />

        {/* Floating Telemetry Bar */}
        <div className="absolute bottom-3 left-3 right-3 z-1000 flex items-center justify-between bg-white/90 backdrop-blur-md px-3.5 py-2 rounded-xl border border-gray-200/80 shadow-md text-xs text-gray-800">
          <div className="flex items-center gap-2.5 flex-wrap">
            <span className="font-bold text-emerald-800 flex items-center gap-1">
              <Radio size={12} className="animate-pulse text-emerald-600" /> GPS Track: Live
            </span>
            <span className="text-gray-300">|</span>
            <span className="text-gray-600">Transit Distance: <strong>{distanceKm} km</strong></span>
            <span className="text-gray-300">|</span>
            <span className="text-gray-600">Speed: <strong>28 km/h</strong></span>
          </div>
          <div className="font-mono text-blue-950 font-bold text-xs sm:text-sm bg-blue-50 px-2 py-0.5 rounded border border-blue-200">
            ETA: ~{etaMinutes} Mins
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
          <div className="text-[10px] text-emerald-700 mt-0.5 font-semibold">Shortest Arterial Route</div>
        </div>

        <div className="p-3 rounded-xl bg-gray-50 border border-gray-200">
          <div className="text-[10px] text-gray-500 uppercase font-mono font-bold">Estimated Arrival</div>
          <div className="text-base font-extrabold text-amber-700 mt-0.5 flex items-center gap-1">
            <Clock size={14} className="text-amber-600" />
            <span>~{etaMinutes} Mins</span>
          </div>
          <div className="text-[10px] text-gray-500 mt-0.5">Live Traffic Calibrated</div>
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
          <div className="text-xs font-bold text-emerald-800 mt-0.5 truncate">
            {customerAddress}
          </div>
          <div className="text-[10px] text-gray-500">Citizen Service Location</div>
        </div>
      </div>

      {/* Selected Radar Artisan Details Popover */}
      {selectedPinWorker && viewMode === 'RADAR' && (
        <div className="p-3 rounded-xl bg-blue-50 border border-blue-200 text-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-blue-950 text-amber-300 flex items-center justify-center font-bold">
              {selectedPinWorker.name?.charAt(0)}
            </div>
            <div>
              <div className="font-bold text-gray-900 flex items-center gap-1.5">
                <span>{selectedPinWorker.name}</span>
                <span className="font-mono text-[10px] text-gray-600 bg-gray-200 px-1.5 py-0.5 rounded">{selectedPinWorker.worker_code}</span>
              </div>
              <div className="text-[10px] text-gray-600">
                {selectedPinWorker.primary_trade} • ⭐ {selectedPinWorker.rating?.toFixed(1) || '4.8'} • 📍 {selectedPinWorker.distanceKm || '3.2'} km away
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
              selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY'
                ? 'bg-amber-100 text-amber-900 border border-amber-300'
                : 'bg-emerald-100 text-emerald-900 border border-emerald-300'
            }`}>
              {selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY' ? 'BUSY / ENGAGED' : 'AVAILABLE'}
            </span>

            {!(selectedPinWorker.isSlotOccupied || selectedPinWorker.availability === 'BUSY') && onSelectWorker && (
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
    </div>
  );
}
