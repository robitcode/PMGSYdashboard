custom_css <- "
/* ---- Design tokens ---- */
:root {
  --navy:   #1B3A5C;
  --amber:  #E8890C;
  --teal:   #0A7C78;
  --red:    #C0392B;
  --sky:    #2980B9;
  --cream:  #F5F0E8;
  --light:  #EEF2F7;
  --muted:  #5D7285;
}

/* ---- Base ---- */
body { background-color: var(--cream) !important; font-family: 'Inter', sans-serif; }

/* ---- Navbar ---- */
.navbar {
  background: linear-gradient(135deg, #0d2137 0%, var(--navy) 60%, #1a4f72 100%) !important;
  border-bottom: 3px solid var(--amber) !important;
  box-shadow: 0 3px 16px rgba(0,0,0,0.25);
  padding: 0.55rem 1rem !important;
}
.navbar-brand { color: #fff !important; font-weight: 700; font-size: 1.15rem; letter-spacing: 0.3px; }
.navbar-brand img { filter: drop-shadow(0 1px 3px rgba(0,0,0,0.4)); }
.nav-link { color: rgba(255,255,255,0.82) !important; font-weight: 500; transition: color 0.2s; }
.nav-link:hover { color: #fff !important; }
.nav-link.active {
  color: var(--amber) !important;
  border-bottom: 2px solid var(--amber) !important;
  font-weight: 700;
}

/* ---- Sidebar ---- */
.sidebar {
  background: #fff !important;
  border-right: 2px solid var(--light);
  box-shadow: 2px 0 12px rgba(0,0,0,0.05);
}
.sidebar .sidebar-title { color: var(--navy); font-weight: 700; font-size: 1rem; }

/* ---- Cards ---- */
.card {
  border-radius: 12px !important;
  border: 1px solid #dce5ef !important;
  box-shadow: 0 2px 10px rgba(0,0,0,0.06);
}
.card-header {
  font-weight: 600 !important;
  background: linear-gradient(90deg, #f0f4f8, #e8edf3) !important;
  border-bottom: 1.5px solid #d0dbe7 !important;
  border-radius: 12px 12px 0 0 !important;
  color: var(--navy);
  font-size: 0.95rem;
}

/* ── Hero card ── */
.hero-card {
  background: linear-gradient(135deg, #0d2137 0%, var(--navy) 45%, #0A7C78 100%) !important;
  border: none !important;
  border-radius: 16px !important;
  position: relative;
  overflow: hidden;
}
.hero-card::after {
  content: '';
  position: absolute;
  top: -80px; right: -80px;
  width: 350px; height: 350px;
  background: rgba(255,255,255,0.04);
  border-radius: 50%;
  pointer-events: none;
}
.hero-card::before {
  content: '';
  position: absolute;
  bottom: -60px; left: -60px;
  width: 260px; height: 260px;
  background: rgba(232,137,12,0.07);
  border-radius: 50%;
  pointer-events: none;
}

/* Stat pills inside hero */
.stat-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: 50px;
  padding: 5px 16px;
  color: #fff;
  font-size: 0.82rem;
  margin: 3px;
  backdrop-filter: blur(4px);
}
.stat-pill .stat-val { font-weight: 800; font-size: 1rem; color: var(--amber); }

/* Feature cards */
.feature-card {
  border-radius: 12px !important;
  border: none !important;
  transition: transform 0.22s ease, box-shadow 0.22s ease;
  overflow: hidden;
}
.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 28px rgba(0,0,0,0.13) !important;
}
.feature-icon-wrap {
  width: 56px; height: 56px;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 12px;
}
.fi-navy  { background: #e6edf5; }
.fi-teal  { background: #e4f4f3; }
.fi-amber { background: #fef3e0; }

/* Phase strips */
.phase-strip {
  border-left: 5px solid var(--amber);
  background: #fff;
  border-radius: 8px;
  padding: 12px 16px;
  margin-bottom: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.phase-strip.phase-teal  { border-color: var(--teal); }
.phase-strip.phase-navy  { border-color: var(--navy); }

/* Impact list */
.impact-item {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 7px 0;
  border-bottom: 1px dashed #e0e8f0;
}
.impact-item:last-child { border-bottom: none; }
.impact-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: var(--teal); margin-top: 6px; flex-shrink: 0;
}

/* Data source pill */
.ds-pill {
  background: var(--light);
  border-radius: 8px;
  padding: 12px 16px;
  font-size: 0.82rem;
  color: var(--muted);
}

/* ── EDA Filter Header ── */
.eda-filter-header {
  background: linear-gradient(90deg, #0d2137 0%, var(--navy) 60%, #1a5276 100%);
  color: #fff;
  border-radius: 12px;
  padding: 14px 20px;
  margin-bottom: 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 3px 14px rgba(27,58,92,0.3);
}
.eda-filter-header h5 { margin: 0; font-weight: 700; font-size: 1rem; }
.filter-badge {
  display: inline-flex; align-items: center; gap: 5px;
  background: rgba(255,255,255,0.12);
  border: 1px solid rgba(255,255,255,0.18);
  border-radius: 20px;
  padding: 3px 12px;
  font-size: 0.78rem;
  color: #fff;
  margin: 2px 4px 0 0;
}
.filter-badge.fb-amber {
  background: var(--amber);
  border-color: var(--amber);
  color: #1a1a1a;
  font-weight: 700;
}

/* Location badge in modal */
.loc-badge {
  display: inline-block;
  background: var(--light);
  color: var(--navy);
  border: 1px solid #c4d3e5;
  border-radius: 20px;
  padding: 4px 13px;
  font-size: 0.8rem;
  font-weight: 600;
  margin: 3px;
  letter-spacing: 0.2px;
}

/* Leaderboard card headers */
.ldb-success { background: var(--teal)  !important; color: #fff !important; border-radius: 11px 11px 0 0 !important; }
.ldb-danger  { background: var(--red)   !important; color: #fff !important; border-radius: 11px 11px 0 0 !important; }

/* Value box tweaks */
.value-box { border-radius: 10px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.08) !important; }

/* Plot background */
.plot-container { background: transparent !important; }

/* Scrollbar */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: #f0f0f0; }
::-webkit-scrollbar-thumb { background: #b0bec5; border-radius: 10px; }
::-webkit-scrollbar-thumb:hover { background: var(--navy); }

/* ---- Card Nav Pills (Leaderboard Tabs) ---- */
.card-header .nav-pills .nav-link {
  color: #000000 !important; 
  font-weight: 600;
  border-radius: 6px;
  padding: 6px 16px !important;
  margin-left: 4px;
  background-color: transparent !important;
  border: 1px solid transparent !important;
}

.card-header .nav-pills .nav-link:hover:not(.active) {
  background-color: #dce5ef !important;
  color: #000000 !important;
}

/* Active Black Button */
.card-header .nav-pills .nav-link.active {
  background-color: #1a1a1a !important; 
  color: #ffffff !important; 
  border-bottom: none !important; 
  box-shadow: 0 2px 5px rgba(0,0,0,0.2);
}

/* ---- Card Nav Pills (Leaderboard Tabs) ---- */
.card-header .nav-pills .nav-link {
  color: #000000 !important; 
  font-weight: 600;
  border-radius: 6px;
  padding: 6px 16px !important;
  margin-left: 4px;
  background-color: transparent !important;
  border: 1px solid transparent !important;
}

.card-header .nav-pills .nav-link:hover:not(.active) {
  background-color: #dce5ef !important;
  color: #000000 !important;
}

/* Active Black Button */
.card-header .nav-pills .nav-link.active {
  background-color: #1a1a1a !important; 
  color: #ffffff !important; 
  border-bottom: none !important; 
  box-shadow: 0 2px 5px rgba(0,0,0,0.2);
}
"