<?xml version="1.0" encoding="utf-8"?>
<!--
  Nmap Security Posture Dashboard XSL
  Transforms nmap XML output into a modern security dashboard.
  Handles: all port states, all scripts, OS detection, CPE, extraports,
  traceroute, host scripts, uptime, distance, and scan metadata.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>

  <xsl:template name="friendly-service">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="$name='ssh'">SSH</xsl:when>
      <xsl:when test="$name='http'">HTTP</xsl:when>
      <xsl:when test="$name='https'">HTTPS</xsl:when>
      <xsl:when test="$name='ssl/http'">HTTPS</xsl:when>
      <xsl:when test="$name='mysql'">MySQL</xsl:when>
      <xsl:when test="$name='domain'">DNS</xsl:when>
      <xsl:when test="$name='msrpc'">RPC</xsl:when>
      <xsl:when test="$name='microsoft-ds'">SMB</xsl:when>
      <xsl:when test="$name='ms-wbt-server'">RDP</xsl:when>
      <xsl:when test="$name='telnet'">Telnet</xsl:when>
      <xsl:when test="$name='snmp'">SNMP</xsl:when>
      <xsl:when test="$name='ftp'">FTP</xsl:when>
      <xsl:when test="$name='smtp'">SMTP</xsl:when>
      <xsl:when test="$name='pop3'">POP3</xsl:when>
      <xsl:when test="$name='imap'">IMAP</xsl:when>
      <xsl:when test="$name='dns'">DNS</xsl:when>
      <xsl:when test="$name='ldap'">LDAP</xsl:when>
      <xsl:when test="$name='kerberos-sec'">Kerberos</xsl:when>
      <xsl:when test="$name='ntp'">NTP</xsl:when>
      <xsl:when test="$name='vnc'">VNC</xsl:when>
      <xsl:when test="$name='smb'">SMB</xsl:when>
      <xsl:otherwise><xsl:value-of select="$name"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <html lang="en" data-theme="dark">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Security Posture Dashboard &#x2014; Nmap <xsl:value-of select="/nmaprun/@version"/></title>
        <script>(function(){var s=localStorage.getItem('theme');if(s)document.documentElement.setAttribute('data-theme',s);})();</script>
        <style>
/*<![CDATA[*/
:root{--bg-main:#F4F6F9;--bg-card:#FFFFFF;--bg-sidebar:#191C24;--bg-input:#F4F6F9;--text-primary:#111827;--text-secondary:#374151;--text-muted:#6B7280;--border-color:#E5E7EB;--accent:#2563EB;--accent-hover:#1D4ED8;--color-crit-bg:#D9534F;--color-crit-text:#FFF;--color-high-bg:#F0AD4E;--color-high-text:#212529;--color-med-bg:#F2CC60;--color-med-text:#111827;--color-low-bg:#56A64B;--color-low-text:#FFF;--color-alert-bg:rgba(217,83,79,.1);--color-alert-border:#D9534F;--color-alert-text:#D9534F;--color-warn-bg:rgba(240,173,78,.1);--color-warn-border:#F0AD4E;--color-warn-text:#F0AD4E}
[data-theme="dark"]{--bg-main:#0d1117;--bg-card:#161b22;--bg-sidebar:#010409;--bg-input:#1c2128;--text-primary:#e6edf3;--text-secondary:#8b949e;--text-muted:#484f58;--border-color:#30363d;--accent:#58a6ff;--accent-hover:#79c0ff;--color-crit-bg:#e02f44;--color-crit-text:#FFF;--color-high-bg:#ff9830;--color-high-text:#0b0b0f;--color-med-bg:#f2cc60;--color-med-text:#111827;--color-low-bg:#56A64B;--color-low-text:#FFF;--color-alert-bg:rgba(224,47,68,.1);--color-alert-border:#e02f44;--color-alert-text:#e02f44;--color-warn-bg:rgba(255,152,48,.1);--color-warn-border:#ff9830;--color-warn-text:#ff9830}
*{box-sizing:border-box;margin:0;padding:0;border-radius:0!important}
html,body{height:100%}
body{font-family:'Segoe UI',Roboto,Helvetica,Arial,sans-serif;background-color:var(--bg-main);color:var(--text-primary);display:flex;min-height:100vh}
a{color:inherit;text-decoration:none}

/* Sidebar */
.sidebar{width:250px;flex-shrink:0;background-color:var(--bg-sidebar);border-right:1px solid var(--border-color);padding:18px 0;display:flex;flex-direction:column;gap:6px;height:100vh;overflow-y:auto;position:sticky;top:0}
.sidebar-section-title{padding:10px 22px 6px;font-size:11px;text-transform:uppercase;letter-spacing:.8px;color:#6e7681;font-weight:700}
.sidebar-item{display:flex;align-items:center;gap:12px;color:#8b949e;cursor:pointer;transition:.15s ease;border-left:3px solid transparent;padding:12px 18px;user-select:none;outline:none}
.sidebar-item:hover,.sidebar-item:focus-visible{background:rgba(255,255,255,.04);color:#e6edf3}
.sidebar-item.active{background:rgba(88,166,255,.10);color:#fff;border-left-color:var(--accent)}
.sidebar-item svg{flex-shrink:0}
.sidebar-item-text{display:flex;flex-direction:column;min-width:0}
.sidebar-label{font-size:14px;font-weight:600}
.sidebar-sub{font-size:11px;color:#6e7681;margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sidebar-subasset{margin-left:18px;padding-left:18px;border-left:1px solid rgba(255,255,255,.08)}
.sidebar-subasset .sidebar-label{font-family:monospace;font-size:13px}

/* Content */
.content{flex-grow:1;padding:30px;overflow-y:auto}
.header{display:flex;justify-content:space-between;align-items:center;margin-bottom:25px;gap:20px}
.header h1{font-size:24px;font-weight:600}
.header-sub{font-size:13px;color:var(--text-muted);margin-top:4px}
.theme-btn,.back-btn{background:var(--bg-input);border:1px solid var(--border-color);color:var(--text-secondary);padding:8px 16px;cursor:pointer;font-size:13px;transition:.15s ease;white-space:nowrap}
.theme-btn:hover,.back-btn:hover{border-color:var(--accent);color:var(--accent)}

/* Pages */
.page-view{display:none}.page-view.active-page{display:block}

/* Scan Info Bar */
.scan-info{font-size:12px;color:var(--text-muted);margin-bottom:20px;padding:12px 15px;background:var(--bg-card);border:1px solid var(--border-color);font-family:'SF Mono','Fira Code',monospace;line-height:1.8}
[data-theme="dark"] .scan-info{background:#0d1117}
.scan-info strong{color:var(--text-primary)}

/* Metrics */
.metrics{display:flex;gap:15px;margin-bottom:25px;flex-wrap:wrap}
.metric-box{flex:1 1 220px;min-width:220px;padding:20px;background:var(--bg-card);border:1px solid var(--border-color);position:relative;overflow:hidden;transition:.15s ease}
[data-theme="dark"] .metric-box,[data-theme="dark"] .viz-card,[data-theme="dark"] .page-block,[data-theme="dark"] .host-card,[data-theme="dark"] .asset-mini-card{background:#0d1117}
.metric-box:hover{border-color:var(--accent);transform:translateY(-1px)}
.metric-box::after{content:"";position:absolute;left:0;bottom:0;width:100%;height:3px;background:var(--accent);opacity:.85}
.metric-box.crit::after{background:var(--color-crit-bg)}.metric-box.warn::after{background:var(--color-high-bg)}
.metric-val{font-size:32px;font-weight:700;font-family:'SF Mono',monospace;line-height:1;margin-bottom:8px}
.metric-box.crit .metric-val{color:var(--color-crit-bg)}.metric-box.warn .metric-val{color:var(--color-high-bg)}
.metric-label{font-size:11px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;font-weight:600}

/* Visual Metrics */
.visual-metrics-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:15px;margin-bottom:25px}
.viz-card,.page-block,.host-card,.asset-mini-card{background:var(--bg-card);border:1px solid var(--border-color)}
.viz-card,.page-block,.asset-mini-card{padding:20px}
.section-title{font-size:11px;text-transform:uppercase;color:var(--text-muted);font-weight:700;margin-bottom:15px;letter-spacing:.8px}
.severity-stack{display:flex;width:100%;height:34px;overflow:hidden;border:1px solid var(--border-color);margin-bottom:15px}
.severity-segment{display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:#fff;font-family:monospace}
.severity-segment.crit{background:var(--color-crit-bg)}.severity-segment.high{background:var(--color-high-bg);color:#111}.severity-segment.med{background:var(--color-med-bg);color:#111}.severity-segment.low{background:var(--color-low-bg)}
.legend-row{display:flex;flex-wrap:wrap;gap:14px;font-size:12px;color:var(--text-secondary)}
.legend-item{display:flex;align-items:center;gap:6px}
.dot{width:10px;height:10px;display:inline-block}
.dot.crit{background:var(--color-crit-bg)}.dot.high{background:var(--color-high-bg)}.dot.med{background:var(--color-med-bg)}.dot.low{background:var(--color-low-bg)}
.exposure-list{display:flex;flex-direction:column;gap:14px}
.exposure-row{display:grid;grid-template-columns:1.4fr 2fr auto;gap:12px;align-items:center;font-size:13px}
.bar-wrap{width:100%;height:10px;background:var(--bg-input);border:1px solid var(--border-color);overflow:hidden}
.bar-fill{height:100%;background:var(--accent);transition:width .4s ease}
.bar-fill.warn{background:var(--color-high-bg)}.bar-fill.crit{background:var(--color-crit-bg)}
.top-services{display:flex;flex-direction:column;gap:12px}
.top-service-row{display:flex;justify-content:space-between;padding-bottom:10px;border-bottom:1px solid var(--border-color);font-size:13px;gap:12px}
.top-service-row:last-child{border-bottom:none;padding-bottom:0}

/* Asset Cards */
.assets-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:15px}
.asset-mini-title{font-size:15px;font-weight:700;font-family:monospace;margin-bottom:4px}
.asset-mini-sub{font-size:12px;color:var(--text-muted);margin-bottom:15px}

/* Host Card */
.card-header{padding:20px 25px 15px;border-bottom:1px solid var(--border-color)}
.host-ip{font-size:18px;font-weight:700;font-family:'SF Mono',monospace}
.hostname{font-size:13px;color:var(--text-muted);margin-top:4px}
.mac-addr{font-size:11px;color:var(--text-muted);font-family:'SF Mono',monospace;margin-top:2px;text-transform:uppercase;letter-spacing:.5px}
[data-theme="dark"] .mac-addr{color:var(--accent);opacity:.8}
.tags{display:flex;gap:8px;margin-top:10px;flex-wrap:wrap}
.tag{font-size:11px;padding:3px 10px;font-weight:500;background:var(--bg-input);color:var(--text-secondary);border:1px solid var(--border-color)}
.tag.os{color:var(--accent);border-color:var(--accent);background:rgba(37,99,235,.08)}
[data-theme="dark"] .tag.os{background:rgba(88,166,255,.15)}

/* Tabs */
.nav-tabs{display:flex;border-bottom:1px solid var(--border-color);padding:0 25px;background:var(--bg-input);flex-wrap:wrap}
.nav-tab{padding:12px 16px;font-size:13px;color:var(--text-muted);background:none;border:none;border-bottom:2px solid transparent;cursor:pointer;font-weight:500;transition:.15s ease}
.nav-tab.active{color:var(--accent);border-bottom-color:var(--accent);background:var(--bg-card)}
.tab-pane{display:none;padding:20px 25px}.tab-pane.active{display:block}

/* Summary Grid */
.summary-grid{display:flex;width:100%;gap:25px}
.col-summary-ports{width:55%;padding-right:25px;border-right:1px solid var(--border-color)}
.col-summary-vulns{width:45%}
.port-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border-color);gap:10px}
.port-row:last-child{border-bottom:none}
.port-info{display:flex;align-items:center;gap:10px}
.port-num{font-family:monospace;font-weight:700;font-size:14px;min-width:40px;color:var(--accent)}
.port-service{font-size:13px;color:var(--text-primary);font-weight:600}
.port-version{font-size:11px;color:var(--text-muted);font-family:monospace;text-align:right;max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}

/* Port State Counts */
.port-state-counts{display:flex;gap:15px;margin-bottom:15px;font-size:12px;flex-wrap:wrap}
.port-state-count{display:flex;align-items:center;gap:5px}

/* State Badges */
.state-badge{display:inline-block;font-size:10px;padding:2px 8px;font-weight:700;text-transform:uppercase;letter-spacing:.3px}
.state-open{background:rgba(86,166,75,.15);color:#56A64B}
.state-filtered{background:rgba(240,173,78,.15);color:#F0AD4E}
.state-closed{background:rgba(107,114,128,.15);color:#6B7280}
.state-open-filtered{background:rgba(88,166,255,.15);color:var(--accent)}
.state-unfiltered{background:rgba(88,166,255,.1);color:var(--accent)}
[data-theme="dark"] .state-open{background:rgba(86,166,75,.2);color:#73d268}
[data-theme="dark"] .state-filtered{background:rgba(255,152,48,.15);color:#ff9830}
[data-theme="dark"] .state-closed{background:rgba(139,148,158,.15);color:#8b949e}

/* Vuln Items */
.vuln-item{margin-bottom:12px;padding-bottom:12px;border-bottom:1px solid var(--border-color)}
.vuln-item:last-child{border-bottom:none;margin-bottom:0;padding-bottom:0}
.vuln-header{display:flex;align-items:center;gap:8px;margin-bottom:4px;flex-wrap:wrap}
.vuln-target{font-size:12px;color:var(--text-muted)}
.cvss-badge{font-size:10px;font-weight:700;padding:2px 6px}
.cvss-crit{background-color:var(--color-crit-bg);color:var(--color-crit-text)}
.cvss-high{background-color:var(--color-high-bg);color:var(--color-high-text)}
.cvss-med{background-color:var(--color-med-bg);color:var(--color-med-text)}
.cvss-low{background-color:var(--color-low-bg);color:var(--color-low-text)}
.cve-link,.asset-link{font-size:13px;font-family:monospace;font-weight:600;color:var(--accent);text-decoration:none;cursor:pointer}
.cve-link:hover,.asset-link:hover{text-decoration:underline}

/* Alert Boxes */
.alert-box{border-left:3px solid var(--color-alert-border);background:var(--color-alert-bg);padding:10px 12px;margin-bottom:15px;font-size:12px;color:var(--text-primary)}
.alert-box.warning{border-left-color:var(--color-warn-border);background:var(--color-warn-bg)}
.alert-title{font-weight:700;color:var(--color-alert-text);display:block;margin-bottom:2px}
.alert-box.warning .alert-title{color:var(--color-warn-text)}
.info-row{font-size:12px;color:var(--text-secondary);margin-bottom:8px;display:flex;align-items:baseline;gap:6px;flex-wrap:wrap}
.info-label{font-weight:600;color:var(--text-muted);min-width:80px}
.info-mono{font-family:monospace;font-size:11px;color:var(--text-muted)}

/* Scripts Tab */
.script-port-header{font-size:14px;font-weight:700;margin:20px 0 10px;padding-bottom:8px;border-bottom:2px solid var(--border-color);color:var(--text-primary);font-family:monospace}
.script-port-header:first-child{margin-top:0}
.script-block{margin-bottom:15px}
.script-id{font-size:13px;font-weight:700;color:var(--accent);margin-bottom:5px;font-family:monospace}
.script-output-pre{background:var(--bg-input);border:1px solid var(--border-color);padding:12px 15px;font-size:12px;font-family:'SF Mono','Fira Code',monospace;overflow-x:auto;white-space:pre-wrap;word-wrap:break-word;color:var(--text-secondary);margin:0}

/* OS Detail */
.os-detail{margin-top:15px;padding-top:15px;border-top:1px solid var(--border-color)}
.os-detail .info-row{margin-bottom:4px}

/* Extraports */
.extraports-info{font-size:12px;color:var(--text-muted);padding:8px 12px;margin-bottom:10px;background:var(--bg-input);border:1px solid var(--border-color)}

/* Tables */
.sub-section{margin-top:15px;padding-top:15px;border-top:1px solid var(--border-color)}
table{width:100%;border-collapse:collapse;margin-bottom:10px}
th,td{text-align:left;padding:10px 12px;border-bottom:1px solid var(--border-color);font-size:13px;vertical-align:top}
th{font-size:11px;color:var(--text-muted);text-transform:uppercase;font-weight:700;background:var(--bg-input);letter-spacing:.5px}
tr:last-child td{border-bottom:none}
.mono{font-family:monospace}
pre{background:var(--bg-input);border:1px solid var(--border-color);padding:15px;font-size:12px;font-family:'SF Mono','Fira Code',monospace;overflow-x:auto;white-space:pre-wrap;word-wrap:break-word;color:var(--text-secondary)}
.asset-detail-topbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;gap:15px;flex-wrap:wrap}

/* Row highlights for port states */
tr.row-open td{border-left:3px solid var(--color-low-bg)}
tr.row-filtered td{border-left:3px solid var(--color-high-bg);opacity:.85}
tr.row-closed td{border-left:3px solid var(--text-muted);opacity:.6}

/* Responsive */
@media(max-width:1200px){.assets-grid{grid-template-columns:1fr}}
@media(max-width:900px){.metrics{flex-direction:column}.summary-grid{flex-direction:column}.col-summary-ports,.col-summary-vulns{width:100%;padding-right:0;border-right:none}.exposure-row{grid-template-columns:1fr}.content{padding:20px}.sidebar{width:210px}}
@media(max-width:640px){.header{flex-direction:column;align-items:flex-start}.nav-tabs{padding:0 12px}.tab-pane{padding:16px}.card-header{padding:16px}.sidebar{width:100px}.sidebar-item-text,.sidebar-section-title{display:none}.sidebar-item{justify-content:center;padding:14px 8px}.sidebar-subasset{margin-left:0;padding-left:0;border-left:none}}
/*]]>*/
        </style>
      </head>
      <body>

        <!-- ===== SIDEBAR ===== -->
        <aside class="sidebar">
          <div class="sidebar-section-title">Navigation</div>
          <div class="sidebar-item active" data-page="dashboard" onclick="switchPage(this)" tabindex="0" role="button" aria-label="Dashboard">
            <svg width="18" height="18" fill="currentColor" viewBox="0 0 16 16"><path d="M0 0h7v7H0V0zm9 0h7v5H9V0zM0 9h5v7H0V9zm7 3h9v4H7v-4z"/></svg>
            <div class="sidebar-item-text"><div class="sidebar-label">Dashboard</div><div class="sidebar-sub">Overview &amp; posture</div></div>
          </div>
          <div class="sidebar-item" data-page="assets" onclick="switchPage(this)" tabindex="0" role="button" aria-label="Assets">
            <svg width="18" height="18" fill="currentColor" viewBox="0 0 16 16"><path d="M1 2.75A1.75 1.75 0 0 1 2.75 1h10.5A1.75 1.75 0 0 1 15 2.75v2.5A1.75 1.75 0 0 1 13.25 7H2.75A1.75 1.75 0 0 1 1 5.25v-2.5zm0 8A1.75 1.75 0 0 1 2.75 9h10.5A1.75 1.75 0 0 1 15 10.75v2.5A1.75 1.75 0 0 1 13.25 15H2.75A1.75 1.75 0 0 1 1 13.25v-2.5z"/></svg>
            <div class="sidebar-item-text"><div class="sidebar-label">Assets</div><div class="sidebar-sub">Asset summary tables</div></div>
          </div>
          <div class="sidebar-section-title">Hosts</div>
          <xsl:for-each select="/nmaprun/host[status/@state='up']">
            <xsl:variable name="ipDashed" select="translate(address/@addr, '.', '-')"/>
            <div class="sidebar-item sidebar-subasset" tabindex="0" role="button">
              <xsl:attribute name="data-asset">asset-<xsl:value-of select="$ipDashed"/></xsl:attribute>
              <xsl:attribute name="onclick">goToAsset('asset-<xsl:value-of select="$ipDashed"/>')</xsl:attribute>
              <xsl:attribute name="aria-label"><xsl:value-of select="address/@addr"/></xsl:attribute>
              <svg width="14" height="14" fill="currentColor" viewBox="0 0 16 16"><path d="M4 4h8v8H4z"/></svg>
              <div class="sidebar-item-text">
                <div class="sidebar-label"><xsl:value-of select="address/@addr"/></div>
                <div class="sidebar-sub"><xsl:value-of select="hostnames/hostname/@name"/></div>
              </div>
            </div>
          </xsl:for-each>
        </aside>

        <!-- ===== MAIN CONTENT ===== -->
        <main class="content">
          <div class="header">
            <div>
              <h1 id="page-title">Dashboard</h1>
              <div class="header-sub" id="page-subtitle">Security posture overview, exposure metrics, and remediation priorities</div>
            </div>
            <button class="theme-btn" onclick="toggleTheme()">Switch Theme</button>
          </div>

          <!-- ===== DASHBOARD ===== -->
          <section id="page-dashboard" class="page-view active-page">

            <!-- Scan Info Bar -->
            <div class="scan-info">
              <strong>$ <xsl:value-of select="/nmaprun/@args"/></strong><br/>
              <xsl:text>Nmap </xsl:text><xsl:value-of select="/nmaprun/@version"/>
              <xsl:text> &#x2014; </xsl:text><xsl:value-of select="/nmaprun/@startstr"/>
              <xsl:text> &#x2013; </xsl:text><xsl:value-of select="/nmaprun/runstats/finished/@timestr"/>
              <xsl:text> &#x2014; </xsl:text><xsl:value-of select="/nmaprun/runstats/finished/@elapsed"/><xsl:text>s elapsed &#x2014; </xsl:text>
              <xsl:value-of select="/nmaprun/runstats/hosts/@up"/> up, <xsl:value-of select="/nmaprun/runstats/hosts/@down"/> down of <xsl:value-of select="/nmaprun/runstats/hosts/@total"/> total
            </div>

            <div class="metrics">
              <div class="metric-box">
                <div class="metric-val" id="metric-hosts"><xsl:value-of select="/nmaprun/runstats/hosts/@up"/></div>
                <div class="metric-label">Live Hosts</div>
              </div>
              <div class="metric-box">
                <div class="metric-val" id="metric-ports"><xsl:value-of select="count(/nmaprun/host[status/@state='up']/ports/port[state/@state='open'])"/></div>
                <div class="metric-label">Open Ports</div>
              </div>
              <div class="metric-box crit">
                <div class="metric-val" id="metric-crit">&#x2014;</div>
                <div class="metric-label">Critical Findings</div>
              </div>
              <div class="metric-box warn">
                <div class="metric-val" id="metric-high">&#x2014;</div>
                <div class="metric-label">High Findings</div>
              </div>
            </div>

            <div class="visual-metrics-grid">
              <div class="viz-card">
                <div class="section-title">Severity Distribution</div>
                <div class="severity-stack">
                  <div class="severity-segment crit" id="sev-crit" style="width:0%"></div>
                  <div class="severity-segment high" id="sev-high" style="width:0%"></div>
                  <div class="severity-segment med"  id="sev-med"  style="width:0%"></div>
                  <div class="severity-segment low"  id="sev-low"  style="width:0%"></div>
                </div>
                <div class="legend-row">
                  <span class="legend-item"><span class="dot crit"></span> Critical</span>
                  <span class="legend-item"><span class="dot high"></span> High</span>
                  <span class="legend-item"><span class="dot med"></span> Medium</span>
                  <span class="legend-item"><span class="dot low"></span> Low</span>
                </div>
              </div>
              <div class="viz-card">
                <div class="section-title">Exposure Overview</div>
                <div class="exposure-list">
                  <div class="exposure-row"><span>Internet-facing Services</span><div class="bar-wrap"><div class="bar-fill" id="exp-internet" style="width:0%"></div></div><span id="exp-internet-val">&#x2014;</span></div>
                  <div class="exposure-row"><span>Legacy Protocols</span><div class="bar-wrap"><div class="bar-fill warn" id="exp-legacy" style="width:0%"></div></div><span id="exp-legacy-val">&#x2014;</span></div>
                  <div class="exposure-row"><span>Weak TLS / Cert Posture</span><div class="bar-wrap"><div class="bar-fill crit" id="exp-tls" style="width:0%"></div></div><span id="exp-tls-val">&#x2014;</span></div>
                </div>
              </div>
              <div class="viz-card">
                <div class="section-title">Top Attack Surface</div>
                <div class="top-services" id="top-services"></div>
              </div>
            </div>

            <!-- Asset Inventory Table -->
            <div class="page-block">
              <div class="section-title">Asset Inventory</div>
              <table>
                <thead><tr><th>IP</th><th>Hostname</th><th>OS</th><th>Vendor</th><th>Risk</th><th>Open Ports</th><th>Filtered</th></tr></thead>
                <tbody>
                  <xsl:for-each select="/nmaprun/host[status/@state='up']">
                    <xsl:variable name="ipDashed" select="translate(address/@addr, '.', '-')"/>
                    <tr>
                      <td><a class="asset-link"><xsl:attribute name="onclick">goToAsset('asset-<xsl:value-of select="$ipDashed"/>')</xsl:attribute><xsl:value-of select="address/@addr"/></a></td>
                      <td><xsl:value-of select="hostnames/hostname/@name"/></td>
                      <td><xsl:value-of select="os/osmatch/@name"/><xsl:if test="os/osmatch/osclass/@type='specialized'"> (IoT)</xsl:if></td>
                      <td>
                        <xsl:choose>
                          <xsl:when test="address/@vendor"><xsl:value-of select="address/@vendor"/></xsl:when>
                          <xsl:when test="address[@addrtype='mac']/@vendor"><xsl:value-of select="address[@addrtype='mac']/@vendor"/></xsl:when>
                        </xsl:choose>
                      </td>
                      <td><span class="cvss-badge"><xsl:attribute name="id">risk-<xsl:value-of select="$ipDashed"/></xsl:attribute>&#x2014;</span></td>
                      <td class="mono">
                        <xsl:for-each select="ports/port[state/@state='open']">
                          <xsl:value-of select="@portid"/><xsl:if test="position()!=last()">, </xsl:if>
                        </xsl:for-each>
                      </td>
                      <td class="mono">
                        <xsl:value-of select="count(ports/port[state/@state='filtered'])"/>
                        <xsl:if test="ports/extraports[@state='filtered']">
                          <xsl:text> (+</xsl:text><xsl:value-of select="ports/extraports[@state='filtered']/@count"/><xsl:text>)</xsl:text>
                        </xsl:if>
                      </td>
                    </tr>
                  </xsl:for-each>
                </tbody>
              </table>
            </div>
          </section>

          <!-- ===== ASSETS PAGE ===== -->
          <section id="page-assets" class="page-view">
            <div class="assets-grid">
              <xsl:for-each select="/nmaprun/host[status/@state='up']">
                <xsl:variable name="ipDashed" select="translate(address/@addr, '.', '-')"/>
                <div class="asset-mini-card">
                  <div class="asset-mini-title"><xsl:value-of select="address/@addr"/></div>
                  <div class="asset-mini-sub"><xsl:value-of select="hostnames/hostname/@name"/></div>
                  <table><tbody>
                    <tr><th>OS</th><td><xsl:value-of select="os/osmatch/@name"/><xsl:if test="os/osmatch/osclass/@type='specialized'"> (IoT)</xsl:if><xsl:if test="os/osmatch/@accuracy"> (<xsl:value-of select="os/osmatch/@accuracy"/>%)</xsl:if></td></tr>
                    <tr><th>Vendor</th><td><xsl:choose><xsl:when test="address/@vendor"><xsl:value-of select="address/@vendor"/></xsl:when><xsl:when test="address[@addrtype='mac']/@vendor"><xsl:value-of select="address[@addrtype='mac']/@vendor"/></xsl:when><xsl:otherwise>&#x2014;</xsl:otherwise></xsl:choose></td></tr>
                    <tr><th>Risk</th><td><span class="cvss-badge"><xsl:attribute name="id">mini-risk-<xsl:value-of select="$ipDashed"/></xsl:attribute>&#x2014;</span></td></tr>
                    <tr><th>Open</th><td class="mono"><xsl:for-each select="ports/port[state/@state='open']"><xsl:value-of select="@portid"/><xsl:if test="position()!=last()">, </xsl:if></xsl:for-each></td></tr>
                    <tr><th>Scripts</th><td><xsl:value-of select="count(ports/port/script)"/> script outputs</td></tr>
                    <tr><th>Top Findings</th><td><xsl:attribute name="id">mini-findings-<xsl:value-of select="$ipDashed"/></xsl:attribute>&#x2014;</td></tr>
                  </tbody></table>
                  <a class="asset-link"><xsl:attribute name="onclick">goToAsset('asset-<xsl:value-of select="$ipDashed"/>')</xsl:attribute>Open Asset View &#x2192;</a>
                </div>
              </xsl:for-each>
            </div>
          </section>

          <!-- ===== PER-HOST DETAIL PAGES ===== -->
          <xsl:for-each select="/nmaprun/host[status/@state='up']">
            <xsl:variable name="hostPos" select="position()"/>
            <xsl:variable name="ipDashed" select="translate(address/@addr, '.', '-')"/>
            <xsl:variable name="hostAddr" select="address/@addr"/>
            <xsl:variable name="hostName" select="hostnames/hostname/@name"/>

            <section class="page-view">
              <xsl:attribute name="id">asset-<xsl:value-of select="$ipDashed"/></xsl:attribute>
              <xsl:attribute name="data-title">Asset View &#x2014; <xsl:value-of select="$hostAddr"/></xsl:attribute>
              <xsl:attribute name="data-subtitle">Host drill-down view for <xsl:value-of select="$hostName"/></xsl:attribute>

              <div class="asset-detail-topbar">
                <button class="back-btn" onclick="goAssets()">&#x2190; Back to Assets</button>
              </div>

              <div class="host-card">
                <div class="card-header">
                  <div>
                    <div class="host-ip"><xsl:value-of select="$hostAddr"/></div>
                    <xsl:if test="$hostName"><div class="hostname"><xsl:value-of select="$hostName"/></div></xsl:if>
                    <!-- MAC Address -->
                    <xsl:if test="address/@mac or address[@addrtype='mac']">
                      <div class="mac-addr">
                        <xsl:choose>
                          <xsl:when test="address/@mac"><xsl:value-of select="address/@mac"/></xsl:when>
                          <xsl:otherwise><xsl:value-of select="address[@addrtype='mac']/@addr"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                          <xsl:when test="address/@vendor"> (<xsl:value-of select="address/@vendor"/>)</xsl:when>
                          <xsl:when test="address[@addrtype='mac']/@vendor"> (<xsl:value-of select="address[@addrtype='mac']/@vendor"/>)</xsl:when>
                        </xsl:choose>
                      </div>
                    </xsl:if>
                    <!-- Tags -->
                    <div class="tags">
                      <xsl:if test="os/osmatch/@name">
                        <span class="tag os"><xsl:value-of select="os/osmatch/@name"/><xsl:if test="os/osmatch/osclass/@type='specialized'"> (IoT)</xsl:if></span>
                      </xsl:if>
                      <xsl:choose>
                        <xsl:when test="address/@vendor"><span class="tag"><xsl:value-of select="address/@vendor"/></span></xsl:when>
                        <xsl:when test="address[@addrtype='mac']/@vendor"><span class="tag"><xsl:value-of select="address[@addrtype='mac']/@vendor"/></span></xsl:when>
                      </xsl:choose>
                      <xsl:if test="os/osmatch/osclass/@type">
                        <span class="tag"><xsl:value-of select="os/osmatch/osclass/@type"/></span>
                      </xsl:if>
                    </div>
                  </div>
                </div>

                <!-- ===== 5 TABS ===== -->
                <div class="nav-tabs">
                  <button class="nav-tab active"><xsl:attribute name="onclick">switchTab(event,'h<xsl:value-of select="$hostPos"/>-summary')</xsl:attribute>Summary</button>
                  <button class="nav-tab"><xsl:attribute name="onclick">switchTab(event,'h<xsl:value-of select="$hostPos"/>-services')</xsl:attribute>Services</button>
                  <button class="nav-tab"><xsl:attribute name="onclick">switchTab(event,'h<xsl:value-of select="$hostPos"/>-scripts')</xsl:attribute>Scripts (<xsl:value-of select="count(ports/port/script) + count(hostscript/script)"/>)</button>
                  <button class="nav-tab"><xsl:attribute name="onclick">switchTab(event,'h<xsl:value-of select="$hostPos"/>-vulns')</xsl:attribute>Vulnerabilities</button>
                  <button class="nav-tab"><xsl:attribute name="onclick">switchTab(event,'h<xsl:value-of select="$hostPos"/>-raw')</xsl:attribute>Raw Output</button>
                </div>

                <!-- ========== SUMMARY TAB ========== -->
                <div class="tab-pane active">
                  <xsl:attribute name="id">h<xsl:value-of select="$hostPos"/>-summary</xsl:attribute>

                  <!-- Port State Counts -->
                  <div class="port-state-counts">
                    <div class="port-state-count"><span class="dot" style="background:var(--color-low-bg)"></span><xsl:value-of select="count(ports/port[state/@state='open'])"/> open</div>
                    <xsl:if test="ports/port[state/@state='filtered'] or ports/extraports[@state='filtered']">
                      <div class="port-state-count"><span class="dot" style="background:var(--color-high-bg)"></span>
                        <xsl:value-of select="count(ports/port[state/@state='filtered'])"/>
                        <xsl:if test="ports/extraports[@state='filtered']"> (+<xsl:value-of select="ports/extraports[@state='filtered']/@count"/>)</xsl:if>
                        <xsl:text> filtered</xsl:text>
                      </div>
                    </xsl:if>
                    <xsl:if test="ports/port[state/@state='closed'] or ports/extraports[@state='closed']">
                      <div class="port-state-count"><span class="dot" style="background:var(--text-muted)"></span>
                        <xsl:value-of select="count(ports/port[state/@state='closed'])"/>
                        <xsl:if test="ports/extraports[@state='closed']"> (+<xsl:value-of select="ports/extraports[@state='closed']/@count"/>)</xsl:if>
                        <xsl:text> closed</xsl:text>
                      </div>
                    </xsl:if>
                  </div>

                  <div class="summary-grid">
                    <div class="col-summary-ports">
                      <div class="section-title">Open Services</div>
                      <xsl:for-each select="ports/port[state/@state='open']">
                        <div class="port-row">
                          <div class="port-info">
                            <span class="port-num"><xsl:value-of select="@portid"/></span>
                            <span class="port-service"><xsl:call-template name="friendly-service"><xsl:with-param name="name" select="service/@name"/></xsl:call-template></span>
                          </div>
                          <span class="port-version"><xsl:value-of select="service/@product"/><xsl:if test="service/@version"><xsl:text> </xsl:text><xsl:value-of select="service/@version"/></xsl:if></span>
                        </div>
                      </xsl:for-each>

                      <!-- OS Detection in Summary -->
                      <xsl:if test="os/osmatch">
                        <div class="os-detail">
                          <div class="section-title">OS Detection</div>
                          <xsl:for-each select="os/osmatch">
                            <div class="info-row"><span class="info-label">OS:</span><xsl:value-of select="@name"/> (<xsl:value-of select="@accuracy"/>%)</div>
                            <xsl:for-each select="osclass">
                              <div class="info-row"><span class="info-label">Type:</span><xsl:value-of select="@type"/> &#x2014; <xsl:value-of select="@vendor"/><xsl:text> </xsl:text><xsl:value-of select="@osfamily"/><xsl:text> </xsl:text><xsl:value-of select="@osgen"/></div>
                              <xsl:if test="cpe"><div class="info-row"><span class="info-label">CPE:</span><span class="info-mono"><xsl:value-of select="cpe"/></span></div></xsl:if>
                            </xsl:for-each>
                          </xsl:for-each>
                        </div>
                      </xsl:if>

                      <!-- Uptime / Distance -->
                      <xsl:if test="uptime/@seconds or distance/@value">
                        <div class="os-detail">
                          <xsl:if test="uptime/@seconds"><div class="info-row"><span class="info-label">Uptime:</span><xsl:value-of select="uptime/@seconds"/>s<xsl:if test="uptime/@lastboot"> (since <xsl:value-of select="uptime/@lastboot"/>)</xsl:if></div></xsl:if>
                          <xsl:if test="distance/@value"><div class="info-row"><span class="info-label">Distance:</span><xsl:value-of select="distance/@value"/> hop(s)</div></xsl:if>
                        </div>
                      </xsl:if>
                    </div>

                    <div class="col-summary-vulns">
                      <div class="section-title">Top Issues</div>
                      <div><xsl:attribute name="id">issues-h<xsl:value-of select="$hostPos"/></xsl:attribute></div>
                    </div>
                  </div>
                </div>

                <!-- ========== SERVICES TAB (ALL PORTS) ========== -->
                <div class="tab-pane">
                  <xsl:attribute name="id">h<xsl:value-of select="$hostPos"/>-services</xsl:attribute>

                  <!-- Extraports summary -->
                  <xsl:for-each select="ports/extraports">
                    <div class="extraports-info">
                      <xsl:value-of select="@count"/> ports <xsl:value-of select="@state"/>
                      <xsl:if test="extrareasons"> (<xsl:for-each select="extrareasons"><xsl:value-of select="@count"/> <xsl:value-of select="@reason"/><xsl:if test="position()!=last()">, </xsl:if></xsl:for-each>)</xsl:if>
                    </div>
                  </xsl:for-each>

                  <table>
                    <thead><tr><th>Port</th><th>Protocol</th><th>State</th><th>Reason</th><th>Service</th><th>Product / Version</th><th>Extra Info</th><th>CPE</th></tr></thead>
                    <tbody>
                      <xsl:for-each select="ports/port">
                        <tr>
                          <xsl:attribute name="class">row-<xsl:value-of select="translate(state/@state,'|','-')"/></xsl:attribute>
                          <td class="mono"><xsl:value-of select="@portid"/></td>
                          <td><xsl:value-of select="translate(@protocol,'tcpud','TCPUD')"/></td>
                          <td><span><xsl:attribute name="class">state-badge state-<xsl:value-of select="translate(state/@state,'|','-')"/></xsl:attribute><xsl:value-of select="state/@state"/></span></td>
                          <td class="mono" style="font-size:11px"><xsl:value-of select="state/@reason"/><xsl:if test="state/@reason_ttl"> (ttl:<xsl:value-of select="state/@reason_ttl"/>)</xsl:if></td>
                          <td><xsl:value-of select="service/@name"/></td>
                          <td class="mono"><xsl:value-of select="service/@product"/><xsl:if test="service/@version"><xsl:text> </xsl:text><xsl:value-of select="service/@version"/></xsl:if></td>
                          <td style="font-size:11px"><xsl:value-of select="service/@extrainfo"/></td>
                          <td class="mono" style="font-size:10px"><xsl:for-each select="service/cpe"><xsl:value-of select="."/><xsl:if test="position()!=last()"><br/></xsl:if></xsl:for-each></td>
                        </tr>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </div>

                <!-- ========== SCRIPTS TAB ========== -->
                <div class="tab-pane">
                  <xsl:attribute name="id">h<xsl:value-of select="$hostPos"/>-scripts</xsl:attribute>

                  <xsl:if test="not(ports/port/script) and not(hostscript/script)">
                    <p style="color:var(--text-muted);font-size:13px">No script output available for this host.</p>
                  </xsl:if>

                  <!-- Per-port scripts -->
                  <xsl:for-each select="ports/port[script]">
                    <div class="script-port-header">
                      <xsl:text>Port </xsl:text><xsl:value-of select="@portid"/>/<xsl:value-of select="@protocol"/>
                      <xsl:if test="service/@name"> &#x2014; <xsl:value-of select="service/@name"/></xsl:if>
                      <xsl:text> (</xsl:text><xsl:value-of select="state/@state"/><xsl:text>)</xsl:text>
                    </div>
                    <xsl:for-each select="script">
                      <div class="script-block">
                        <div class="script-id"><xsl:value-of select="@id"/></div>
                        <pre class="script-output-pre"><xsl:value-of select="@output"/></pre>
                      </div>
                    </xsl:for-each>
                  </xsl:for-each>

                  <!-- Host-level scripts -->
                  <xsl:if test="hostscript/script">
                    <div class="script-port-header">Host Scripts</div>
                    <xsl:for-each select="hostscript/script">
                      <div class="script-block">
                        <div class="script-id"><xsl:value-of select="@id"/></div>
                        <pre class="script-output-pre"><xsl:value-of select="@output"/></pre>
                      </div>
                    </xsl:for-each>
                  </xsl:if>

                  <!-- Traceroute -->
                  <xsl:if test="trace/hop">
                    <div class="script-port-header">Traceroute (<xsl:value-of select="trace/@proto"/> port <xsl:value-of select="trace/@port"/>)</div>
                    <table>
                      <thead><tr><th>TTL</th><th>RTT</th><th>Address</th><th>Host</th></tr></thead>
                      <tbody>
                        <xsl:for-each select="trace/hop">
                          <tr>
                            <td><xsl:value-of select="@ttl"/></td>
                            <td><xsl:value-of select="@rtt"/> ms</td>
                            <td class="mono"><xsl:value-of select="@ipaddr"/></td>
                            <td><xsl:value-of select="@host"/></td>
                          </tr>
                        </xsl:for-each>
                      </tbody>
                    </table>
                  </xsl:if>
                </div>

                <!-- ========== VULNERABILITIES TAB ========== -->
                <div class="tab-pane">
                  <xsl:attribute name="id">h<xsl:value-of select="$hostPos"/>-vulns</xsl:attribute>
                  <div><xsl:attribute name="id">vulns-h<xsl:value-of select="$hostPos"/></xsl:attribute></div>
                </div>

                <!-- ========== RAW OUTPUT TAB ========== -->
                <div class="tab-pane">
                  <xsl:attribute name="id">h<xsl:value-of select="$hostPos"/>-raw</xsl:attribute>
                  <pre>
<xsl:text>Nmap scan report for </xsl:text><xsl:value-of select="$hostAddr"/><xsl:if test="$hostName"> (<xsl:value-of select="$hostName"/>)</xsl:if>
<xsl:text>
Host is </xsl:text><xsl:value-of select="status/@state"/><xsl:text> (</xsl:text><xsl:value-of select="status/@reason"/><xsl:text>).
</xsl:text>
<xsl:if test="address/@mac or address[@addrtype='mac']"><xsl:text>MAC Address: </xsl:text><xsl:choose><xsl:when test="address/@mac"><xsl:value-of select="address/@mac"/></xsl:when><xsl:otherwise><xsl:value-of select="address[@addrtype='mac']/@addr"/></xsl:otherwise></xsl:choose><xsl:choose><xsl:when test="address/@vendor"> (<xsl:value-of select="address/@vendor"/>)</xsl:when><xsl:when test="address[@addrtype='mac']/@vendor"> (<xsl:value-of select="address[@addrtype='mac']/@vendor"/>)</xsl:when></xsl:choose>
</xsl:if>
<xsl:if test="ports/extraports"><xsl:text>Not shown: </xsl:text><xsl:for-each select="ports/extraports"><xsl:value-of select="@count"/><xsl:text> </xsl:text><xsl:value-of select="@state"/> ports<xsl:if test="position()!=last()">, </xsl:if></xsl:for-each>
</xsl:if>
<xsl:text>
PORT      STATE     SERVICE        VERSION
</xsl:text>
<xsl:for-each select="ports/port"><xsl:value-of select="@portid"/>/<xsl:value-of select="@protocol"/><xsl:text>    </xsl:text><xsl:value-of select="state/@state"/><xsl:text>    </xsl:text><xsl:value-of select="service/@name"/><xsl:text>    </xsl:text><xsl:value-of select="service/@product"/><xsl:if test="service/@version"><xsl:text> </xsl:text><xsl:value-of select="service/@version"/></xsl:if><xsl:if test="service/@extrainfo"><xsl:text> </xsl:text><xsl:value-of select="service/@extrainfo"/></xsl:if>
</xsl:for-each>
<xsl:if test="ports/port/script or hostscript/script">
<xsl:text>
SCRIPT OUTPUT:
</xsl:text>
<xsl:for-each select="ports/port[script]"><xsl:text>| </xsl:text><xsl:value-of select="@portid"/>/<xsl:value-of select="@protocol"/><xsl:text>:
</xsl:text><xsl:for-each select="script"><xsl:text>|   </xsl:text><xsl:value-of select="@id"/><xsl:text>: </xsl:text>
<xsl:value-of select="@output"/>
</xsl:for-each></xsl:for-each>
<xsl:if test="hostscript/script"><xsl:text>| Host scripts:
</xsl:text><xsl:for-each select="hostscript/script"><xsl:text>|   </xsl:text><xsl:value-of select="@id"/><xsl:text>: </xsl:text>
<xsl:value-of select="@output"/>
</xsl:for-each></xsl:if></xsl:if>
<xsl:if test="os/osmatch">
<xsl:text>
OS DETECTION:
</xsl:text>
<xsl:for-each select="os/osmatch"><xsl:text>  </xsl:text><xsl:value-of select="@name"/> (<xsl:value-of select="@accuracy"/>%)
<xsl:for-each select="osclass"><xsl:text>    Type: </xsl:text><xsl:value-of select="@type"/><xsl:text>  Vendor: </xsl:text><xsl:value-of select="@vendor"/><xsl:text>  OS: </xsl:text><xsl:value-of select="@osfamily"/><xsl:text> </xsl:text><xsl:value-of select="@osgen"/>
<xsl:if test="cpe"><xsl:text>    CPE: </xsl:text><xsl:value-of select="cpe"/>
</xsl:if></xsl:for-each></xsl:for-each></xsl:if>
<xsl:if test="uptime/@seconds">
<xsl:text>Uptime: </xsl:text><xsl:value-of select="uptime/@seconds"/>s<xsl:if test="uptime/@lastboot"> (since <xsl:value-of select="uptime/@lastboot"/>)</xsl:if>
</xsl:if>
<xsl:if test="distance/@value">
<xsl:text>Network Distance: </xsl:text><xsl:value-of select="distance/@value"/> hop(s)
</xsl:if>
<xsl:if test="trace/hop">
<xsl:text>
TRACEROUTE:
HOP  RTT      ADDRESS          HOST
</xsl:text>
<xsl:for-each select="trace/hop"><xsl:value-of select="@ttl"/><xsl:text>    </xsl:text><xsl:value-of select="@rtt"/>ms<xsl:text>    </xsl:text><xsl:value-of select="@ipaddr"/><xsl:text>    </xsl:text><xsl:value-of select="@host"/>
</xsl:for-each></xsl:if></pre>
                </div>
              </div>
            </section>
          </xsl:for-each>
        </main>

        <!-- ===== HIDDEN SCAN DATA FOR JS ===== -->
        <div id="scan-data" style="display:none">
          <xsl:for-each select="/nmaprun/host[status/@state='up']">
            <div class="sd-host">
              <xsl:attribute name="data-ip"><xsl:value-of select="address/@addr"/></xsl:attribute>
              <xsl:attribute name="data-hostname"><xsl:value-of select="hostnames/hostname/@name"/></xsl:attribute>
              <xsl:attribute name="data-os"><xsl:value-of select="os/osmatch/@name"/></xsl:attribute>
              <xsl:attribute name="data-os-type"><xsl:value-of select="os/osmatch/osclass/@type"/></xsl:attribute>
              <xsl:attribute name="data-vendor"><xsl:choose><xsl:when test="address/@vendor"><xsl:value-of select="address/@vendor"/></xsl:when><xsl:when test="address[@addrtype='mac']/@vendor"><xsl:value-of select="address[@addrtype='mac']/@vendor"/></xsl:when></xsl:choose></xsl:attribute>
              <!-- ALL ports, all states -->
              <xsl:for-each select="ports/port">
                <div class="sd-port">
                  <xsl:attribute name="data-portid"><xsl:value-of select="@portid"/></xsl:attribute>
                  <xsl:attribute name="data-protocol"><xsl:value-of select="@protocol"/></xsl:attribute>
                  <xsl:attribute name="data-state"><xsl:value-of select="state/@state"/></xsl:attribute>
                  <xsl:attribute name="data-reason"><xsl:value-of select="state/@reason"/></xsl:attribute>
                  <xsl:attribute name="data-service"><xsl:value-of select="service/@name"/></xsl:attribute>
                  <xsl:attribute name="data-product"><xsl:value-of select="service/@product"/></xsl:attribute>
                  <xsl:attribute name="data-version"><xsl:value-of select="service/@version"/></xsl:attribute>
                  <xsl:attribute name="data-extrainfo"><xsl:value-of select="service/@extrainfo"/></xsl:attribute>
                  <xsl:attribute name="data-tunnel"><xsl:value-of select="service/@tunnel"/></xsl:attribute>
                  <xsl:for-each select="service/cpe">
                    <div class="sd-cpe"><xsl:value-of select="."/></div>
                  </xsl:for-each>
                  <xsl:for-each select="script">
                    <div class="sd-script">
                      <xsl:attribute name="data-id"><xsl:value-of select="@id"/></xsl:attribute>
                      <xsl:value-of select="@output"/>
                    </div>
                  </xsl:for-each>
                </div>
              </xsl:for-each>
              <!-- Extraports -->
              <xsl:for-each select="ports/extraports">
                <div class="sd-extraports">
                  <xsl:attribute name="data-state"><xsl:value-of select="@state"/></xsl:attribute>
                  <xsl:attribute name="data-count"><xsl:value-of select="@count"/></xsl:attribute>
                </div>
              </xsl:for-each>
              <!-- Host-level scripts -->
              <xsl:for-each select="hostscript/script">
                <div class="sd-hostscript">
                  <xsl:attribute name="data-id"><xsl:value-of select="@id"/></xsl:attribute>
                  <xsl:value-of select="@output"/>
                </div>
              </xsl:for-each>
            </div>
          </xsl:for-each>
        </div>

        <!-- ===== JAVASCRIPT ===== -->
        <script>
//<![CDATA[
function toggleTheme(){var c=document.documentElement.getAttribute('data-theme');var n=c==='dark'?'light':'dark';document.documentElement.setAttribute('data-theme',n);localStorage.setItem('theme',n)}
function clearPages(){var v=document.querySelectorAll('.page-view');for(var i=0;i<v.length;i++)v[i].classList.remove('active-page')}
function clearSidebar(){var s=document.querySelectorAll('.sidebar-item');for(var i=0;i<s.length;i++)s[i].classList.remove('active')}
function activateParentAssets(){var e=document.querySelector('.sidebar-item[data-page="assets"]');if(e)e.classList.add('active')}
function switchPage(el){var p=el.getAttribute('data-page');clearPages();clearSidebar();if(p==='dashboard'){document.getElementById('page-dashboard').classList.add('active-page');el.classList.add('active');document.getElementById('page-title').textContent='Dashboard';document.getElementById('page-subtitle').textContent='Security posture overview, exposure metrics, and remediation priorities'}if(p==='assets'){document.getElementById('page-assets').classList.add('active-page');el.classList.add('active');document.getElementById('page-title').textContent='Assets';document.getElementById('page-subtitle').textContent='Asset summary tables and per-host drill-down navigation'}}
function goToAsset(id){clearPages();clearSidebar();var p=document.getElementById(id);if(p){p.classList.add('active-page');document.getElementById('page-title').textContent=p.getAttribute('data-title')||'Asset View';document.getElementById('page-subtitle').textContent=p.getAttribute('data-subtitle')||''}activateParentAssets();var s=document.querySelector('.sidebar-item[data-asset="'+id+'"]');if(s)s.classList.add('active')}
function goAssets(){var e=document.querySelector('.sidebar-item[data-page="assets"]');switchPage(e)}
function switchTab(evt,tabId){var card=evt.target.closest('.host-card');if(!card)return;var tabs=card.querySelectorAll('.nav-tab');for(var i=0;i<tabs.length;i++)tabs[i].classList.remove('active');var panes=card.querySelectorAll('.tab-pane');for(var i=0;i<panes.length;i++)panes[i].classList.remove('active');evt.target.classList.add('active');var t=card.querySelector('#'+tabId);if(t)t.classList.add('active')}
function esc(t){var d=document.createElement('div');d.appendChild(document.createTextNode(t));return d.innerHTML}
function getServiceCategory(s){var m={'http':'HTTP / HTTPS','https':'HTTP / HTTPS','ssl/http':'HTTP / HTTPS','microsoft-ds':'SMB / RPC','msrpc':'SMB / RPC','ssh':'SSH','telnet':'Telnet','snmp':'SNMP','domain':'DNS','mysql':'MySQL','ms-wbt-server':'RDP','ftp':'FTP','smtp':'SMTP','pop3':'POP3','imap':'IMAP','ldap':'LDAP','kerberos-sec':'Kerberos','ntp':'NTP','vnc':'VNC'};return m[s]||s.toUpperCase()}

function computeAll(){
  var hosts=document.querySelectorAll('.sd-host');
  var allFindings=[];
  var totalOpenPorts=0;
  var totalFilteredPorts=0;
  var totalClosedPorts=0;
  var serviceCategories={};

  for(var hi=0;hi<hosts.length;hi++){
    var host=hosts[hi];
    var ip=host.getAttribute('data-ip');
    var ports=host.querySelectorAll('.sd-port');

    // Count extraports
    var extras=host.querySelectorAll('.sd-extraports');
    for(var ei=0;ei<extras.length;ei++){
      var es=extras[ei].getAttribute('data-state');
      var ec=parseInt(extras[ei].getAttribute('data-count'))||0;
      if(es==='filtered')totalFilteredPorts+=ec;
      if(es==='closed')totalClosedPorts+=ec;
    }

    for(var pi=0;pi<ports.length;pi++){
      var port=ports[pi];
      var pState=port.getAttribute('data-state')||'';
      var svc=port.getAttribute('data-service')||'';
      var product=port.getAttribute('data-product')||'';
      var version=port.getAttribute('data-version')||'';
      var extrainfo=port.getAttribute('data-extrainfo')||'';
      var portid=port.getAttribute('data-portid');
      var svcDesc=(product+' '+version).trim();

      if(pState==='open'){
        totalOpenPorts++;
        var cat=getServiceCategory(svc);
        serviceCategories[cat]=(serviceCategories[cat]||0)+1;
      }else if(pState==='filtered'){
        totalFilteredPorts++;
      }else if(pState==='closed'){
        totalClosedPorts++;
      }

      // Only analyze open ports for findings
      if(pState!=='open')continue;

      // Cleartext protocols
      if(svc==='telnet'||svc==='ftp'){
        allFindings.push({host:ip,hostIdx:hi,finding:'Cleartext Protocol ('+svc+')',score:7.5,type:'cleartext',service:'Port '+portid})
      }
      // SNMP exposure
      if(svc==='snmp'){
        allFindings.push({host:ip,hostIdx:hi,finding:'SNMP Exposure',score:5.0,type:'exposure',service:'Port '+portid})
      }

      // Parse ALL scripts on this port
      var scripts=port.querySelectorAll('.sd-script');
      for(var si=0;si<scripts.length;si++){
        var script=scripts[si];
        var sid=script.getAttribute('data-id');
        var output=script.textContent;

        // vulners → extract CVEs
        if(sid==='vulners'){
          var re=/(CVE-\d{4}-\d+)\s+([\d.]+)\s+(https?:\/\/\S+)/g;
          var m;while((m=re.exec(output))!==null){
            allFindings.push({host:ip,hostIdx:hi,cve:m[1],score:parseFloat(m[2]),url:m[3],service:svcDesc,port:portid,type:'cve'})
          }
        }

        // smb-vuln-*, vuln-* scripts (not vulners)
        if(sid.indexOf('vuln')!==-1&&sid!=='vulners'){
          var cm=output.match(/CVE[:\s]+(CVE-\d{4}-\d+)/);
          var desc=output.match(/vulnerability[^\n]*/i);
          if(cm){
            allFindings.push({host:ip,hostIdx:hi,cve:cm[1],score:9.8,service:svc+' (Port '+portid+')',port:portid,type:'vuln-script',description:desc?desc[0]:sid})
          }
        }

        // ssl-cert
        if(sid==='ssl-cert'){
          if(output.indexOf('EXPIRED')!==-1){
            var im=output.match(/Issuer:\s*commonName=([^\n]+)/);
            var em=output.match(/Expiration Date:\s*([^\s]+)/);
            allFindings.push({host:ip,hostIdx:hi,finding:'SSL Certificate Expired',score:7.5,type:'cert-expired',service:'Port '+portid,issuer:im?im[1]:'Unknown',expiry:em?em[1]:'Unknown'})
          }
          if(output.indexOf('Self-Signed')!==-1){
            allFindings.push({host:ip,hostIdx:hi,finding:'Self-Signed Certificate',score:7.0,type:'cert-selfsigned',service:'Port '+portid})
          }
        }

        // http-title with interesting titles
        if(sid==='http-title'&&(output.indexOf('401')!==-1||output.indexOf('403')!==-1||output.indexOf('Default')!==-1)){
          allFindings.push({host:ip,hostIdx:hi,finding:'HTTP: '+output.trim(),score:3.0,type:'info-http',service:'Port '+portid})
        }

        // banner revealing device info
        if(sid==='banner'){
          allFindings.push({host:ip,hostIdx:hi,finding:'Banner Disclosure',score:3.5,type:'info-banner',service:'Port '+portid,details:output.trim().split('\n')[0]})
        }

        // snmp-processes (information disclosure)
        if(sid==='snmp-processes'||sid==='snmp-sysdescr'||sid==='snmp-info'){
          allFindings.push({host:ip,hostIdx:hi,finding:'SNMP Information Disclosure ('+sid+')',score:5.0,type:'info-snmp',service:'Port '+portid})
        }

        // rdp-ntlm-info (information disclosure)
        if(sid==='rdp-ntlm-info'){
          allFindings.push({host:ip,hostIdx:hi,finding:'RDP NTLM Information Disclosure',score:4.0,type:'info-rdp',service:'Port '+portid})
        }

        // msrpc-enum
        if(sid==='msrpc-enum'){
          allFindings.push({host:ip,hostIdx:hi,finding:'MSRPC Endpoint Enumeration',score:4.0,type:'info-rpc',service:'Port '+portid})
        }
      }
    }

    // Host-level scripts
    var hscripts=host.querySelectorAll('.sd-hostscript');
    for(var hsi=0;hsi<hscripts.length;hsi++){
      var hs=hscripts[hsi];
      var hsid=hs.getAttribute('data-id');
      var hsout=hs.textContent;
      if(hsid.indexOf('vuln')!==-1){
        var hcm=hsout.match(/CVE[:\s]+(CVE-\d{4}-\d+)/);
        if(hcm){allFindings.push({host:ip,hostIdx:hi,cve:hcm[1],score:9.8,service:'Host Script',type:'vuln-script',description:hsid})}
      }
    }
  }

  // Deduplicate CVE findings per host
  var seen={};var deduped=[];
  for(var i=0;i<allFindings.length;i++){
    var f=allFindings[i];
    var key=f.host+'|'+(f.cve||f.finding||'')+f.type;
    if(!seen[key]){seen[key]=1;deduped.push(f)}
  }
  allFindings=deduped;

  // Categorize
  var crit=[],high=[],med=[],low=[];
  for(var i=0;i<allFindings.length;i++){
    var f=allFindings[i];
    if(f.score>=9.0)crit.push(f);
    else if(f.score>=7.0)high.push(f);
    else if(f.score>=4.0)med.push(f);
    else if(f.score>0)low.push(f);
  }
  document.getElementById('metric-crit').textContent=crit.length;
  document.getElementById('metric-high').textContent=high.length;

  // Severity distribution
  var total=allFindings.length||1;
  setSevBar('sev-crit',crit.length,total);
  setSevBar('sev-high',high.length,total);
  setSevBar('sev-med',med.length,total);
  setSevBar('sev-low',low.length,total);

  // Exposure overview
  var webCount=0,legacyCount=0,certCount=0;
  var openPorts=document.querySelectorAll('.sd-port[data-state="open"]');
  for(var i=0;i<openPorts.length;i++){
    var s=openPorts[i].getAttribute('data-service');
    if(s==='http'||s==='https'||s==='ssl/http')webCount++;
    if(s==='telnet'||s==='ftp'||s==='snmp'||s==='finger'||s==='rlogin')legacyCount++;
  }
  for(var i=0;i<allFindings.length;i++){if(allFindings[i].type&&allFindings[i].type.indexOf('cert')===0)certCount++}
  setExpBar('exp-internet','exp-internet-val',webCount,totalOpenPorts);
  setExpBar('exp-legacy','exp-legacy-val',legacyCount,totalOpenPorts);
  setExpBar('exp-tls','exp-tls-val',certCount,hosts.length);

  // Top Attack Surface
  var sorted=[];for(var k in serviceCategories)sorted.push([k,serviceCategories[k]]);
  sorted.sort(function(a,b){return b[1]-a[1]});
  var ts=document.getElementById('top-services');
  for(var i=0;i<sorted.length;i++){
    var r=document.createElement('div');r.className='top-service-row';
    r.innerHTML='<span>'+esc(sorted[i][0])+'</span><strong>'+sorted[i][1]+' Exposure'+(sorted[i][1]!==1?'s':'')+'</strong>';
    ts.appendChild(r)
  }

  // Risk badges & mini card findings
  for(var hi=0;hi<hosts.length;hi++){
    var ip=hosts[hi].getAttribute('data-ip');
    var ipD=ip.replace(/\./g,'-');
    var hf=[];for(var i=0;i<allFindings.length;i++){if(allFindings[i].host===ip)hf.push(allFindings[i])}
    var ms=0;for(var i=0;i<hf.length;i++){if(hf[i].score>ms)ms=hf[i].score}
    var b1=document.getElementById('risk-'+ipD);if(b1)setRisk(b1,ms);
    var b2=document.getElementById('mini-risk-'+ipD);if(b2)setRisk(b2,ms);
    var fc=document.getElementById('mini-findings-'+ipD);
    if(fc){var sm=[];for(var i=0;i<hf.length&&sm.length<3;i++){var s=hf[i].cve||hf[i].finding;if(s)sm.push(s)}fc.textContent=sm.length>0?sm.join(', '):'No findings'}
  }

  populateHostVulns(allFindings,hosts);
}

function setSevBar(id,c,t){var e=document.getElementById(id);if(!e)return;var p=Math.round(c/t*100);e.style.width=p+'%';e.textContent=p>0?p+'%':''}
function setExpBar(b,v,c,t){var bar=document.getElementById(b);var val=document.getElementById(v);if(!bar||!val)return;var p=t>0?Math.round(c/t*100):0;bar.style.width=p+'%';val.textContent=p+'%'}
function setRisk(el,s){if(s>=9){el.className='cvss-badge cvss-crit';el.textContent='CRITICAL'}else if(s>=7){el.className='cvss-badge cvss-high';el.textContent='HIGH'}else if(s>=4){el.className='cvss-badge cvss-med';el.textContent='MEDIUM'}else{el.className='cvss-badge cvss-low';el.textContent='LOW'}}

function populateHostVulns(allFindings,hosts){
  for(var hi=0;hi<hosts.length;hi++){
    var ip=hosts[hi].getAttribute('data-ip');
    var hf=[];for(var i=0;i<allFindings.length;i++){if(allFindings[i].host===ip)hf.push(allFindings[i])}
    // Sort by score desc
    hf.sort(function(a,b){return b.score-a.score});
    var hNum=hi+1;

    // Summary tab issues
    var ic=document.getElementById('issues-h'+hNum);
    if(ic){
      var h='';
      // Critical alerts first
      for(var i=0;i<hf.length;i++){var f=hf[i];
        if(f.type==='cert-expired')h+='<div class="alert-box"><span class="alert-title">SSL Certificate Expired</span>Issuer: '+esc(f.issuer||'Unknown')+' (Expired '+esc(f.expiry||'Unknown')+')</div>';
        if(f.type==='vuln-script')h+='<div class="alert-box"><span class="alert-title">CRITICAL: '+esc(f.description||f.cve)+'</span>Remote Code Execution vulnerability. Missing patch.</div>';
        if(f.type==='cleartext')h+='<div class="alert-box warning"><span class="alert-title">HIGH: Cleartext Protocol</span>'+esc(f.finding)+' exposes credentials in plaintext.</div>';
      }
      // CVE items
      for(var i=0;i<hf.length;i++){var f=hf[i];
        if(f.type==='cve'){var sc=f.score>=9?'cvss-crit':f.score>=7?'cvss-high':f.score>=4?'cvss-med':'cvss-low';
          h+='<div class="vuln-item"><div class="vuln-header"><span class="cvss-badge '+sc+'">'+f.score+'</span><a href="'+(f.url||'#')+'" target="_blank" class="cve-link">'+esc(f.cve)+'</a></div><div class="vuln-target">'+esc(f.service)+'</div></div>'
        }
      }
      // Info items
      for(var i=0;i<hf.length;i++){var f=hf[i];
        if(f.type==='cert-selfsigned')h+='<div class="info-row"><span class="info-label">SSL:</span> Self-Signed Certificate ('+esc(f.service)+')</div>';
        if(f.type==='exposure')h+='<div class="info-row"><span class="info-label">Exposure:</span> '+esc(f.finding)+'</div>';
        if(f.type==='info-banner')h+='<div class="info-row"><span class="info-label">Banner:</span> '+esc(f.details||f.finding)+'</div>';
        if(f.type==='info-snmp')h+='<div class="info-row"><span class="info-label">Info Leak:</span> '+esc(f.finding)+'</div>';
        if(f.type==='info-rdp')h+='<div class="info-row"><span class="info-label">Info Leak:</span> '+esc(f.finding)+'</div>';
        if(f.type==='info-rpc')h+='<div class="info-row"><span class="info-label">Info Leak:</span> '+esc(f.finding)+'</div>';
        if(f.type==='info-http')h+='<div class="info-row"><span class="info-label">HTTP:</span> '+esc(f.finding)+'</div>';
      }
      if(hf.length===0)h='<p style="color:var(--text-muted);font-size:13px">No security findings detected.</p>';
      ic.innerHTML=h
    }

    // Vulnerabilities tab
    var vc=document.getElementById('vulns-h'+hNum);
    if(vc){
      var h='';
      // Alert boxes
      for(var i=0;i<hf.length;i++){var f=hf[i];
        if(f.type==='cert-expired')h+='<div class="alert-box"><span class="alert-title">SSL Certificate Expired</span>Port utilizes an expired certificate (Expired: '+esc(f.expiry||'Unknown')+'). Issuer: '+esc(f.issuer||'Unknown')+'.</div>';
        if(f.type==='vuln-script')h+='<div class="alert-box"><span class="alert-title">CRITICAL: '+esc(f.cve)+'</span>The remote host is missing critical security patches.</div>';
        if(f.type==='cleartext')h+='<div class="alert-box warning"><span class="alert-title">HIGH: Cleartext Protocol</span>Cleartext '+esc(f.finding)+' is active. Credentials transmitted in plaintext.</div>';
      }
      // CVE table
      var cves=[];for(var i=0;i<hf.length;i++){if(hf[i].cve)cves.push(hf[i])}
      if(cves.length>0){
        h+='<table><thead><tr><th>Severity</th><th>CVE ID</th><th>Service</th><th>CVSS</th></tr></thead><tbody>';
        for(var i=0;i<cves.length;i++){var f=cves[i];
          var sev=f.score>=9?'CRITICAL':f.score>=7?'HIGH':f.score>=4?'MEDIUM':'LOW';
          var sc=f.score>=9?'cvss-crit':f.score>=7?'cvss-high':f.score>=4?'cvss-med':'cvss-low';
          h+='<tr><td><span class="cvss-badge '+sc+'">'+sev+'</span></td><td><a href="'+(f.url||'#')+'" target="_blank" class="cve-link">'+esc(f.cve)+'</a></td><td>'+esc(f.service)+'</td><td class="mono">'+f.score+'</td></tr>'
        }
        h+='</tbody></table>'
      }
      // Other findings table
      var others=[];for(var i=0;i<hf.length;i++){if(!hf[i].cve&&hf[i].finding)others.push(hf[i])}
      if(others.length>0){
        h+='<div class="section-title" style="margin-top:20px">Additional Findings</div>';
        h+='<table><thead><tr><th>Severity</th><th>Finding</th><th>Details</th></tr></thead><tbody>';
        for(var i=0;i<others.length;i++){var f=others[i];
          var sev=f.score>=9?'CRITICAL':f.score>=7?'HIGH':f.score>=4?'MEDIUM':'LOW';
          var sc=f.score>=9?'cvss-crit':f.score>=7?'cvss-high':f.score>=4?'cvss-med':'cvss-low';
          h+='<tr><td><span class="cvss-badge '+sc+'">'+sev+'</span></td><td>'+esc(f.finding)+'</td><td class="mono">'+esc(f.service)+'</td></tr>'
        }
        h+='</tbody></table>'
      }
      if(hf.length===0)h='<p style="color:var(--text-muted);font-size:13px">No vulnerabilities detected.</p>';
      vc.innerHTML=h
    }
  }
}

document.addEventListener('DOMContentLoaded',function(){
  computeAll();
  var items=document.querySelectorAll('.sidebar-item');
  for(var i=0;i<items.length;i++){items[i].addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();this.click()}})}
});
//]]>
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
