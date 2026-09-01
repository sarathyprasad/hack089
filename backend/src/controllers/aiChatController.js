const { query } = require('../db/connection');

// Dynamic openers to ensure varied, non-repetitive conversational phrasing
const OPENERS = [
  "Namaste! Let me assist you with that right away.",
  "Hello! I am happy to help troubleshoot and guide you on Shram Setu.",
  "Welcome! Here is the exact technical and cooperative guidance for your request:",
  "Thanks for reaching out! Let me break this down clearly for you:",
  "Glad you asked! Here is the official diagnostic and service information:",
  "I'm on it! Let me guide you through the solution and standard tariffs:",
];

/**
 * Helper to query active catalog services from database
 */
async function getCatalogContext() {
  try {
    const servicesRes = await query('SELECT id, name, category, base_price, description FROM services ORDER BY category, base_price');
    const workerCountRes = await query("SELECT COUNT(*) as count FROM workers WHERE verification_status = 'VERIFIED'");
    return {
      services: servicesRes.rows || [],
      verifiedWorkers: parseInt(workerCountRes.rows[0]?.count || 15, 10),
    };
  } catch (err) {
    return { services: [], verifiedWorkers: 15 };
  }
}

/**
 * Dynamic Intelligent Problem Diagnostic & Troubleshooting Engine
 */
function diagnoseHouseholdProblem(msg) {
  const m = msg.toLowerCase();
  const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];

  // ── 1. TAP NOT WORKING / LEAKING / WATER DRIPPING / CLOGGED ──
  if (
    m.includes('tap') ||
    m.includes('faucet') ||
    m.includes('nal') ||
    m.includes('water not coming') ||
    m.includes('dripping') ||
    (m.includes('leak') && (m.includes('sink') || m.includes('washbasin') || m.includes('basin') || m.includes('kitchen')))
  ) {
    const variations = [
      {
        angle: 'Aerator & Cartridge Focus',
        causes: [
          '**Blocked Aerator Mesh**: Mineral scaling and sand particles from hard water often choke the spout filter.',
          '**Worn Ceramic Cartridge / Washer**: Continuous usage erodes the inner silicone washer, causing either zero flow or persistent dripping.',
          '**Concealed Angle Valve Blockage**: The shut-off valve below the sink may be half-closed or jammed with sediment.',
        ],
        diy: '1. Unscrew the small aerator cap at the tip of the tap spout by hand or with a cloth-wrapped coin. Rinse out trapped grit under water.\n2. Verify that the angle valve under your sink/basin is turned fully counter-clockwise.\n3. ⚠️ *Caution: Do not use excessive force with iron pliers on CPVC fittings as it may crack the wall pipe.*',
      },
      {
        angle: 'Spindle & Water Pressure Focus',
        causes: [
          '**Worn Brass Spindle**: The internal threading may have slipped, causing the knob to spin without lifting the valve.',
          '**Air Lock in Main Distribution Line**: If the overhead tank recently ran dry, trapped air bubbles can restrict flow to specific taps.',
          '**Debris in Supply Inlet**: Rust flakes or pipe sealant tape can lodge behind the quarter-turn cartridge.',
        ],
        diy: '1. Try turning on an adjacent tap at the same height to test if the issue is localized to one faucet.\n2. Gently remove the tap aerator mesh and clean it with mild vinegar or warm water.\n3. ⚠️ *Caution: If the tap is dripping under the wall tile, keep the main overhead tank valve closed until the technician arrives.*',
      },
    ];

    const selectedVar = pick(variations);
    const opener = pick(OPENERS);

    return {
      reply: `${opener}\n\n### 🚰 Problem Diagnosis: Tap / Faucet Malfunction\n\n**Probable Technical Causes**:\n${selectedVar.causes.map((c) => `• ${c}`).join('\n')}\n\n**💡 Immediate Safe DIY Troubleshooting Steps**:\n${selectedVar.diy}\n\n---\n\n### 🏛️ Official Government Service & Tariff\n• **Standard Labour Base Tariff**: **₹249** *(Zero surge pricing)*\n• **Statutory 90-5-5 Split**: 90% direct to artisan (₹224.10), 5% ESIC worker welfare fund (₹12.45), 5% platform operations (₹12.45)\n• **Standard ISI Replacement Parts**: Ceramic Disc Cartridge (₹120–₹180), Teflon Seal Tape (₹20), Brass Spindle (₹160)\n• **Cooperative Assurance**: 2-Stage Security OTP (Arrival & Completion) + **7-Day Free Repair Guarantee** with ₹0 labour cost if fault recurs.`,
      suggestions: [
        'Book a Plumber for Tap Repair (₹249)',
        'Check Nearby Plumbers on Live Radar',
        'How does 7-Day Free Warranty work?',
        'How does 2-Stage OTP Handshake work?',
      ],
      links: [
        { label: '🚰 Book Tap Repair Plumber (₹249)', url: '/book-service?category=Plumbing&problem=Tap%20Not%20Working' },
        { label: '🗺️ View Nearby Plumbers on Live Radar', url: '/find-worker?trade=Plumbing' },
        { label: '📜 View All Plumbing Tariffs', url: '/services' },
      ],
    };
  }

  // ── 2. MCB TRIPPING / SWITCH SPARKING / ELECTRICAL FAULTS ──
  if (
    m.includes('mcb') ||
    m.includes('tripping') ||
    m.includes('spark') ||
    m.includes('short circuit') ||
    m.includes('switchboard') ||
    m.includes('shock') ||
    m.includes('fuse')
  ) {
    const opener = pick(OPENERS);
    return {
      reply: `${opener}\n\n### ⚡ Problem Diagnosis: Electrical Fault / MCB Tripping\n\n**Probable Technical Causes**:\n• **Circuit Overload**: High-draw appliances (geyser, AC, heater) exceeding the 6A/16A rating of the circuit breaker.\n• **Neutral / Phase Short Circuit**: Worn wire insulation or rodent damage touching metallic conduit boxes.\n• **Carbonized Switch Terminals**: Loose terminal screws creating micro-arcs and heat buildup.\n• **Moisture Leakage into Concealed Box**: High humidity or wall seepage near junction boxes.\n\n**🚨 Critical Safety Precautions**:\n1. **DO NOT repeatedly force the MCB toggle up** if it immediately snaps down. This indicates an active ground/short fault.\n2. Unplug all heavy appliances from the affected room before attempting a single reset.\n3. Keep hands dry and wear rubber-soled footwear.\n\n---\n\n### 🏛️ Official Cooperative Service & Tariff\n• **Standard Labour Base Tariff**: **₹199** *(Fixed rate)*\n• **Master-Artisan Quality Assurance**: High-voltage complex tasks are paired with a certified Senior Master Electrician at **₹0 extra cost**.\n• **Standard ISI Parts**: Havells/Anchor 16A/32A MCB (₹180–₹260), ISI 2.5mm Copper Wire (₹35/m), Modular Switches (₹45–₹90)\n• **Warranty**: 7-Day Free Cooperative Repair Guarantee.`,
      suggestions: [
        'Book Certified Electrician (₹199)',
        'Check Emergency Electrical Dispatch',
        'Find Nearby Electricians',
      ],
      links: [
        { label: '⚡ Book Electrician (₹199)', url: '/book-service?category=Electrical&problem=MCB%20Tripping' },
        { label: '🗺️ Find Nearby Electricians', url: '/find-worker?trade=Electrical' },
      ],
    };
  }

  // ── 3. AC NOT COOLING / REFRIGERATOR ISSUES ──
  if (
    m.includes('ac') ||
    m.includes('cooling') ||
    m.includes('air conditioner') ||
    m.includes('fridge') ||
    m.includes('refrigerator') ||
    m.includes('gas refill')
  ) {
    const opener = pick(OPENERS);
    return {
      reply: `${opener}\n\n### ❄️ Problem Diagnosis: AC / Refrigerator Low Cooling\n\n**Probable Technical Causes**:\n• **Clogged Indoor Filter Mesh**: Thick dust layer choking airflow over cooling fins.\n• **Low Refrigerant (Gas) Level**: Micro-leakage in copper pipe flare joints requiring nitrogen pressure testing and R32/R410A top-up.\n• **Failed 45uF Run Capacitor**: Outdoor compressor motor failing to kick in while indoor blower runs warm.\n• **Dirty Outdoor Condenser Unit**: Mud/dust clogging outdoor heat dissipation coils.\n\n**💡 Immediate Safe DIY Steps**:\n1. Open front indoor AC flap, slide out plastic mesh filters, wash under running water and dry completely before reinserting.\n2. Ensure room doors and windows are tightly closed, and temperature is set to 24°C in 'Cool' mode.\n\n---\n\n### 🏛️ Standardized Regulated Tariffs\n• **AC Diagnostic & Deep Foam Jet Service**: **₹499** *(Zero summer surge pricing)*\n• **Refrigerant Gas Top-Up (R32 / R410A)**: Fixed cooperative rate with digital manifold pressure gauge verification\n• **Appliance Lineage Recorded**: Maintenance service logged into digital history for warranty tracing.`,
      suggestions: [
        'Book AC Master Mechanic (₹499)',
        'Check AC Gas Refill Rates',
        'How 7-Day Guarantee Works',
      ],
      links: [
        { label: '❄️ Book AC Service (₹499)', url: '/book-service?category=Appliance%20Repair&problem=AC%20Not%20Cooling' },
        { label: '📜 View Appliance Tariffs', url: '/services' },
      ],
    };
  }

  // ── 4. CEILING FAN MAKING NOISE / NOT ROTATING ──
  if (m.includes('fan') || m.includes('ceiling fan') || m.includes('humming') || m.includes('slow speed')) {
    const opener = pick(OPENERS);
    return {
      reply: `${opener}\n\n### ⚡ Problem Diagnosis: Ceiling Fan Humming / Slow Speed\n\n**Probable Causes**:\n• **Weakened 2.5uF Motor Capacitor**: Reduces starting torque, causing motor to hum without rotating at full speed.\n• **Dry or Jammed Ball Bearings (6201/6202)**: Lack of high-temperature grease causing grinding noise or resistance.\n• **Defective Electronic Regulator**: Voltage potentiometer malfunctioning.\n\n**💡 Quick DIY Check**: Turn off fan switch. Use a clean stick to gently spin fan blades by hand. If blades spin freely, the capacitor is likely degraded; if stiff, bearings require greasing.\n\n---\n\n• **Labour Base Rate**: **₹199**\n• **Parts**: Heavy-Duty 2.5uF Capacitor (₹60), Sealed Ball Bearings (₹110)\n• **Warranty**: 7-Day Free Cooperative Repair Guarantee.`,
      suggestions: ['Book Fan Electrician (₹199)', 'Find Nearby Electrician'],
      links: [{ label: '⚡ Book Fan Repair (₹199)', url: '/book-service?category=Electrical&problem=Ceiling%20Fan%20Repair' }],
    };
  }

  // ── 5. WATER TANK OVERFLOW / DRAINAGE / PUMP ──
  if (m.includes('tank') || m.includes('overflow') || m.includes('pump') || m.includes('motor') || m.includes('drain') || m.includes('blockage')) {
    const opener = pick(OPENERS);
    return {
      reply: `${opener}\n\n### 🚰 Problem Diagnosis: Water Tank / Drainage / Pump Issue\n\n**Probable Causes**:\n• **Damaged Heavy-Duty Float Valve**: Rubber stopper inside overhead tank valve is punctured, causing overflow.\n• **Airlock / Impeller Jam in Water Pump**: Dry running or sand particles lodged in pump housing.\n• **Organic Sludge & Hair Trap in Drains**: Blocking kitchen sink/bathroom drain traps.\n\n• **Standard Labour Tariff**: **₹249 - ₹349**\n• **Parts**: Brass/PVC Float Valve (₹140–₹220), Pressure Seal Kit (₹90)\n• **Protection**: 2-Stage OTP Handshake & 7-Day Guarantee.`,
      suggestions: ['Book Plumber Now (₹249)', 'Emergency Plumbing Helpline'],
      links: [{ label: '🚰 Book Plumbing Service', url: '/book-service?category=Plumbing&problem=Water%20Tank%20Overflow' }],
    };
  }

  // ── 6. DOOR LOCK JAMMED / HINGE / CARPENTRY ──
  if (m.includes('door') || m.includes('lock') || m.includes('key') || m.includes('handle') || m.includes('hinge') || m.includes('wardrobe') || m.includes('carpenter')) {
    const opener = pick(OPENERS);
    return {
      reply: `${opener}\n\n### 🔨 Problem Diagnosis: Door Lock Jam / Carpentry Issue\n\n**Probable Causes**:\n• **Misaligned Latch Bolt**: Door frame settling or wood swelling due to humidity causing striker plate friction.\n• **Internal Brass Pin Seizure**: Dust inside key cylinder.\n• **Loose Hydraulic Hinge**: Cabinet hinges slipping out of screw anchor.\n\n• **Standard Base Tariff**: **₹299**\n• **Standard Parts**: Godrej/Europa Brass Lock (₹450–₹950), SS Ball Bearing Hinges (₹120)\n• **Warranty**: 7-Day Free Workmanship Guarantee.`,
      suggestions: ['Book Carpenter (₹299)', 'Find Nearby Carpenter'],
      links: [{ label: '🔨 Book Carpentry Service', url: '/book-service?category=Carpentry&problem=Door%20Lock%20Jammed' }],
    };
  }

  return null;
}

/**
 * Intelligent semantic rule-based response generator with dynamic variations
 */
function generateContextualResponse(userMessage, history = [], catalog = {}, lang = 'EN') {
  const msg = userMessage.toLowerCase().trim();
  const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];
  const opener = pick(OPENERS);

  // First, check if user is asking about a specific household diagnostic problem (e.g. tap, fan, MCB, AC)
  const diagnosticResult = diagnoseHouseholdProblem(userMessage);
  if (diagnosticResult) {
    return diagnosticResult;
  }

  // 1. Emergency / SOS
  if (msg.includes('sos') || msg.includes('emergency') || msg.includes('urgent') || msg.includes('shock') || msg.includes('fire') || msg.includes('burst')) {
    return {
      reply: `🚨 **EMERGENCY ASSISTANCE ACTIVE**\n\nFor immediate safety hazards:\n• **National Emergency Helpline**: Dial [112](tel:112)\n• **Medical Ambulance**: Dial [108](tel:108)\n• **Shram Setu 24/7 Rapid Dispatch**: Dial [1800-345-7788](tel:18003457788)\n\nOur cooperative emergency priority dispatch mobilizes a verified master technician within **30 minutes** for major water line bursts or electrical short-circuits.`,
      suggestions: ['Book 24/7 Emergency Service', 'Call Toll-Free Helpline', 'View Active SOS Status'],
      links: [{ label: '⚡ Book Emergency Repair', url: '/book-service?emergency=true' }],
    };
  }

  // 2. 90-5-5 Revenue Split & Cooperative Welfare
  if (msg.includes('90-5-5') || msg.includes('split') || msg.includes('commission') || msg.includes('welfare') || msg.includes('esic') || msg.includes('social security')) {
    const variations = [
      `🏛️ **Transparent 90-5-5 Statutory Tariff Architecture**:\n\nUnlike commercial aggregator apps that extract 25%–35% middleman commission, **Shram Setu** operates on a regulated cooperative model:\n\n• **90%**: Directly paid to the verified artisan's wallet for their skilled labour.\n• **5%**: Deposited into the **Worker Welfare Fund** for ESIC accident insurance, medical coverage, and retirement corpus.\n• **5%**: Capped platform operations and server maintenance.\n\nEvery booking you make directly empowers skilled blue-collar artisans!`,
      `💰 **How the 90-5-5 Fair Wage Split Protects Artisans & Citizens**:\n\nBy state cooperative bylaws, every rupee is accounted for transparently:\n\n1. **90% Worker Take-Home**: Fair, guaranteed earnings with zero commission deductions.\n2. **5% Social Security Net**: Automated healthcare and accident insurance pooling under ESIC.\n3. **5% Platform Infrastructure**: Covers digital services and helpline operations.\n\nNo surge pricing, no arbitrary contractor markups!`,
    ];

    return {
      reply: `${opener}\n\n${pick(variations)}`,
      suggestions: ['View All Standardized Tariffs', 'How to Book a Service', 'Artisan Welfare Fund Details'],
      links: [{ label: '📊 View Transparent Tariffs', url: '/services' }, { label: '🏢 Learn About Cooperative Model', url: '/about' }],
    };
  }

  // 3. 2-Stage OTP Handshake
  if (msg.includes('otp') || msg.includes('handshake') || msg.includes('arrival') || msg.includes('completion otp') || msg.includes('security code')) {
    return {
      reply: `${opener}\n\n🔐 **Two-Stage Cryptographic Security Handshake**:\n\nTo protect citizens from unauthorized entries and premature billing, Shram Setu enforces a strict 2-step OTP verification:\n\n1. **Arrival OTP (4 Digits)**: Generated when your order is dispatched. Share this with the artisan *only upon their arrival* at your doorstep to initiate the work session.\n2. **Completion OTP (4 Digits)**: Generated after repairs. Share this *only when you are 100% satisfied* with the completed work. Entering this OTP releases the artisan wage and automatically arms your **7-Day Free Repair Guarantee**!`,
      suggestions: ['Check Active Booking Status', 'How to Claim 7-Day Guarantee', 'Book a Verified Artisan'],
      links: [{ label: '📋 View My Bookings', url: '/customer/bookings' }],
    };
  }

  // 4. 7-Day Guarantee / Warranty
  if (msg.includes('guarantee') || msg.includes('warranty') || msg.includes('repair failed') || msg.includes('issue again') || msg.includes('complaint') || msg.includes('dispute')) {
    return {
      reply: `${opener}\n\n🛡️ **7-Day Free Cooperative Repair Guarantee**:\n\nEvery job completed through Shram Setu is backed by an automated 7-day workmanship warranty:\n\n• If the same technical issue or defect recurs within **7 days** of service completion, simply go to your booking details or dispute desk.\n• Click **"Claim Free Re-dispatch"**.\n• A certified **Senior Master Artisan** will be dispatched to resolve the issue with **₹0 labour charges**.\n• All replacement parts carry standard manufacturer ISI warranties.`,
      suggestions: ['Open Dispute & Guarantee Desk', 'View Form IV Tax Bill', 'Book a New Service'],
      links: [{ label: '🛡️ Open My Bookings & Guarantee', url: '/customer/bookings' }, { label: '⚖️ Grievance Helpdesk', url: '/help' }],
    };
  }

  // 5. Pricing, Rates & Tariffs Inquiry
  if (msg.includes('price') || msg.includes('tariff') || msg.includes('rate') || msg.includes('cost') || msg.includes('how much') || msg.includes('charge')) {
    const serviceListText = catalog.services && catalog.services.length > 0
      ? catalog.services.slice(0, 6).map((s) => `• **${s.name}** (${s.category}): Base rate ₹${s.base_price}`).join('\n')
      : `• **Electrical Repairs & Wiring**: Base rate ₹199\n• **Plumbing & Leakage Fix**: Base rate ₹249\n• **AC Service & Gas Refill**: Base rate ₹499\n• **Carpentry & Lock Replacement**: Base rate ₹299`;

    return {
      reply: `${opener}\n\n💰 **Standardized Government-Regulated Tariffs (Zero Surge Pricing)**:\n\nAll rates are fixed by the Cooperative Federation with **zero hidden surge charges**:\n\n${serviceListText}\n\n*Note: Total bill includes standard 90-5-5 breakdown (90% labour, 5% welfare, 5% ops) plus official Form IV GST tax bill.*`,
      suggestions: ['Book a Service Now', 'Find Nearest Available Artisan', 'How Does 90-5-5 Split Work?'],
      links: [{ label: '📜 View Full Service Catalog', url: '/services' }, { label: '📅 Book a Service', url: '/book-service' }],
    };
  }

  // 6. General Greetings / Default Fallback with Context
  const generalGreetings = [
    `${opener}\n\nI can help you with:\n1. 🛠️ **Service Booking & Diagnostics**: Tell me any repair issue (e.g. *my tap is not working*, *MCB tripping*, *AC not cooling*).\n2. 💰 **Transparent Pricing**: Check government 90-5-5 base rates.\n3. 🛡️ **Guarantees**: Learn about 2-stage OTP handshakes and 7-Day Free Repair Guarantee.\n4. 👷 **Artisan Registration**: Join as an accredited cooperative worker member.\n\nWhat repair or question can I help you with right now?`,
    `${opener}\n\nWhether you need an immediate plumber, electrician, carpenter, AC mechanic, or want to check official cooperative service rates, I'm here to assist!\n\nSimply describe your home problem or ask about our transparent 90-5-5 pricing.`,
  ];

  return {
    reply: pick(generalGreetings),
    suggestions: [
      'My tap is not working',
      'MCB switch is tripping',
      'AC is not cooling',
      'How does the 90-5-5 split work?',
      'How does the 2-Stage OTP work?',
      'How to claim 7-Day Free Guarantee?',
    ],
    links: [
      { label: '📅 Book a Service Now', url: '/book-service' },
      { label: '📜 Browse Standard Services', url: '/services' },
      { label: '📞 24x7 Helpline: 1800-345-7788', url: 'tel:18003457788' },
    ],
  };
}

/**
 * POST /api/smart-features/ai-chat
 * Process user prompt with multi-turn context and knowledge retrieval.
 */
async function handleAIChat(req, res) {
  try {
    const { message, history = [], language = 'EN', role = 'CITIZEN' } = req.body;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({ error: 'Message text is required.' });
    }

    // 1. Fetch live catalog context from PostgreSQL
    const catalog = await getCatalogContext();

    // 2. Check if external LLM API key is present (Gemini)
    let aiResponse = null;

    if (process.env.GEMINI_API_KEY) {
      try {
        const fetch = global.fetch || require('node-fetch');
        const systemPrompt = `You are "Sahayak AI", the official virtual assistant for Shram Setu, the National Cooperative Gig Services Platform supported by the Government of India and Ministry of Cooperation.
Platform Facts:
- 90-5-5 statutory revenue split: 90% direct to artisan wage, 5% worker welfare/ESIC medical/accident fund, 5% platform operations.
- Zero surge pricing and regulated government tariffs.
- If the user describes a problem (e.g. "my tap is not working", "mcb tripping", "ac not cooling"), provide:
  1. Technical causes in simple terms.
  2. Safe DIY check.
  3. Standard base tariff (Plumbing ₹249, Electrical ₹199, AC ₹499, Carpentry ₹299).
  4. Mention 2-stage OTP handshake & 7-Day Free Guarantee.
- Keep responses dynamic, varied, polite, and markdown formatted.`;

        const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`;
        const contents = [
          { role: 'user', parts: [{ text: systemPrompt }] },
          ...history.slice(-6).map((h) => ({
            role: h.role === 'assistant' ? 'model' : 'user',
            parts: [{ text: h.content }],
          })),
          { role: 'user', parts: [{ text: message }] },
        ];

        const geminiRes = await fetch(geminiUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents }),
        });

        const geminiData = await geminiRes.json();
        const generatedText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text;

        if (generatedText) {
          aiResponse = {
            reply: generatedText,
            suggestions: ['Book a Service Now', 'Check Tariffs', 'How Does 90-5-5 Work?'],
            links: [{ label: '📅 Book a Service', url: '/book-service' }, { label: '📜 View Tariffs', url: '/services' }],
          };
        }
      } catch (externalErr) {
        console.warn('External AI API call fallback:', externalErr.message);
      }
    }

    // 3. If no external LLM or error, use our intelligent contextual engine
    if (!aiResponse) {
      aiResponse = generateContextualResponse(message, history, catalog, language);
    }

    return res.json({
      success: true,
      data: {
        reply: aiResponse.reply,
        suggestions: aiResponse.suggestions || [],
        links: aiResponse.links || [],
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err) {
    console.error('AI Chat Error:', err);
    res.status(500).json({
      error: 'Chat Processing Error',
      message: 'Failed to process AI chat message. Please try again.',
    });
  }
}

module.exports = {
  handleAIChat,
};
