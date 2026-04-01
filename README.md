<div align="center">

# Awesomenmap

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/0xbugatti/Awesomenmap/main/.github/logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/0xbugatti/Awesomenmap/main/.github/logo-light.svg">
  <img alt="Awesomenmap" src="https://raw.githubusercontent.com/0xbugatti/Awesomenmap/main/.github/logo-dark.svg" width="420">
</picture>

<br>

**A Curated Knowledge Base for Nmap Scripts, CVE Intelligence & Automated Reconnaissance Pipelines**

[![Nmap](https://img.shields.io/badge/Nmap-7.x%2B-46A046?logo=nmap&logoColor=white)](https://nmap.org/)
[![NSE](https://img.shields.io/badge/NSE-Scripts-FF6600?style=flat)](https://nmap.org/book/nse.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-informational)]()

*A living reference of essential Nmap extensions, vulnerability feeds, and reporting tooling — maintained for security analysts, pentesters, and blue teams.*

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Core NSE Script Updates](#-core-nse-script-updates)
- [Alternative: Vulscan Integration](#-alternative-vulscan-integration)
- [NSE Script Collections](#-nse-script-collections)
- [CVE Search CLI Tools](#-cve-search-cli-tools)
- [Dashboard & Task Automation](#-dashboard--task-automation)
- [Reporting & Notifications](#-reporting--notifications)

---

## 🎯 Overview

**Awesomenmap** is a knowledge-base repository that centralizes the most valuable Nmap NSE scripts, CVE search utilities, and post-scan reporting pipelines into a single, well-organized reference. Rather than hunting across dozens of GitHub repos and forum posts, security practitioners can use this project as a definitive index and automation hub for all things Nmap.

The repository is intentionally kept lightweight — it contains structured `README` files, configuration templates, and automation wrappers. Large binary or third-party script files are referenced via their upstream sources and pulled in through a simple sync mechanism described below.

Key capabilities this project enables:

| Capability | Description |
|---|---|
| **Script Management** | Pull and update the latest vulnerability, default-account, and version-detection NSE scripts from trusted upstream sources |
| **CVE Intelligence** | Search known CVEs and exploits directly from the command line without leaving your terminal |
| **Automated Scanning** | A dashboard-driven workflow assigns scanning targets, executes Nmap with the curated script set, and produces structured output |
| **Rich Reporting** | Generate HTML scan reports and Graphviz-compatible dependency graphs for every completed scan |
| **Real-time Alerts** | Push critical findings to a Telegram bot for instant visibility |

---

## 📂 Repository Structure

```
Awesomenmap/
│
├── README.md                          # ← You are here
├── LICENSE
├── .gitignore
│
├── scripts/
│   ├── nse/                           # Curated NSE scripts (symlinks or copies)
│   │   ├── vulners.nse                # Vulners.com vulnerability detection
│   │   ├── nndefaccts.nse             # Default account credential checker
│   │   ├── vicarius-nmap/             # Vicarius CVE mapping scripts
│   │   ├── vulscan/                   # Vulscan alternative engine
│   │   ├── log4shell_nse.nse          # Log4Shell (CVE-2021-44228) detector
│   │   ├── ms-exchange-version.nse    # MS Exchange version enumeration
│   │   └── gitlab-version.nse         # GitLab version enumeration
│   │
│   └── cli/                           # CVE & exploit search tools
│       ├── getsploit/                 # Vulners.com exploit downloader
│       └── search_vulns/              # Multi-source CVE searcher
│
└── visualize/
    ├── nmap-dashboard.xsl
    └── nmap-formatter/
```

---

## 🔧 Core NSE Script Updates

These scripts form the backbone of the vulnerability detection workflow. Keep them up to date by pulling from their official upstream repositories.

### 1. Vulners — Vulnerability Detection

> **Source:** [vulnersCom/nmap-vulners](https://github.com/vulnersCom/nmap-vulners/blob/master/vulners.nse)

The Vulners NSE script queries the [Vulners.com](https://vulners.com/) API to match detected service versions against a comprehensive vulnerability database, returning associated CVEs, CVSS scores, and available exploit references in real time.

```bash
# Clone / update
cd scripts/nse/
git clone https://github.com/vulnersCom/nmap-vulners.git
cp nmap-vulners/vulners.nse ./
```

**Example usage:**

```bash
nmap -sV --script vulners.nse --script-args vulnersdebug=1 <target>
```

---

### 2. Default Accounts — Credential Auditing

> **Source:** [nnposter/nndefaccts](https://github.com/nnposter/nndefaccts)

This script checks network services for default or well-known credentials. It ships with an extensive, regularly updated dictionary of default username/password pairs covering routers, cameras, IoT devices, industrial controllers, and enterprise software. It is invaluable during initial reconnaissance when assessing whether exposed services are using factory-default authentication that could be trivially compromised by an attacker.

```bash
# Clone / update
cd scripts/nse/
git clone https://github.com/nnposter/nndefaccts.git
cp nndefaccts/nndefaccts.nse ./
```

**Example usage:**

```bash
nmap -p 22,23,80,443,8080 --script nndefaccts.nse <target>
```

---

### 3. Vicarius Nmap — CVE Mapping

> **Source:** [VicariusInc/vicarius-nmap](https://github.com/VicariusInc/vicarius-nmap)

Vicarius provides an alternative CVE mapping engine that cross-references detected software versions with their vulnerability database. It complements the Vulners script by offering a second opinion on CVE coverage and can surface discrepancies or additional vulnerabilities that one database might miss. The script is particularly strong for detecting known vulnerabilities in less common or niche software packages that may not receive immediate coverage in larger databases.

```bash
# Clone / update
cd scripts/nse/
git clone https://github.com/VicariusInc/vicarius-nmap.git
cp -r vicarius-nmap/scripts/* ./
```

**Example usage:**

```bash
nmap -sV --script vicarius-cve <target>
```

---

## 🔄 Alternative: Vulscan Integration

> **Source:** [scipag/vulscan](https://github.com/scipag/vulscan?tab=readme-ov-file)

If you prefer a self-contained, offline-capable alternative to the API-dependent Vulners script, **Vulscan** is an excellent choice. It ships with local vulnerability databases and can be extended with custom CSV/JSON feeds. Vulscan performs version-string matching against its bundled databases, making it suitable for air-gapped environments or scenarios where internet access during scanning is restricted or undesirable.

```bash
# Clone / update
cd scripts/nse/
git clone https://github.com/scipag/vulscan.git
```

**Example usage:**

```bash
nmap -sV --script=vulscan/vulscan.nse <target>
```

> **Tip:** You can use Vulners *and* Vulscan together for maximum coverage — Vulscan as the offline baseline and Vulners for real-time API enrichment.

---

## 📦 NSE Script Collections

These community-maintained collections provide additional NSE scripts that expand Nmap's detection capabilities beyond the official script library. Each collection has been vetted for quality and relevance. Periodically pull the latest versions to ensure you have the most current detection signatures and vulnerability checks available.

| Collection | Source | Focus |
|---|---|---|
| **nmap-extra-nse** | [sighook/nmap-extra-nse](https://github.com/sighook/nmap-extra-nse) | General-purpose auxiliary scripts not yet merged into the official Nmap distribution, including custom service probes and brute-force modules |
| **NSE_scripts** | [icarot/NSE_scripts](https://github.com/icarot/NSE_scripts/tree/master) | Vulnerability detection and information-gathering scripts tailored for web application auditing and service enumeration |
| **Custom-Nse** | [ibrahmsql/Custom-Nse](https://github.com/ibrahmsql/Custom-Nse) | Individually crafted NSE scripts targeting specific vulnerabilities, unusual protocols, and emerging threat landscapes |
| **log4shell_nse** | [righel/log4shell_nse](https://github.com/righel/log4shell_nse) | Dedicated detector for Log4Shell (CVE-2021-44228) in Java-based services, performing both header-based and DNS-based verification |
| **ms-exchange-version** | [righel/ms-exchange-version-nse](https://github.com/righel/ms-exchange-version-nse) | Precise Microsoft Exchange Server version fingerprinting, essential for rapidly assessing Patch Tuesday compliance and ProxyShell/ProxyLogon exposure |
| **gitlab-version** | [righel/gitlab-version-nse](https://github.com/righel/gitlab-version-nse) | GitLab instance version detection and associated CVE identification, helping prioritize remediation for self-hosted DevOps infrastructure |
| **Official Nmap Scripts** | [nmap/nmap/scripts](https://github.com/nmap/nmap/tree/master/scripts) | The canonical upstream repository — always ensure your local scripts are at least as recent as this tree |

---

## 🔎 CVE Search CLI Tools

These command-line utilities let you search for CVEs and exploits without switching context to a browser. They integrate seamlessly into shell scripts, CI pipelines, and the Awesomenmap automation workflow described later in this document.

### GetSploit — Vulners.com Exploit Finder

> **Source:** [vulnersCom/getsploit](https://github.com/vulnersCom/getsploit)

A lightweight Python-based CLI that queries the Vulners.com database for exploit code, shellcode, and proof-of-concept implementations associated with a given CVE identifier or software version string. It returns direct links to exploit source code along with metadata such as publication date, exploit platform, and reliability rating.

```bash
# Install
pip install getsploit

# Search
getsploit -s "Apache Struts 2"
getsploit -s CVE-2021-44228
```

---

### search_vulns — Multi-Source CVE Search

> **Source:** [ra1nb0rn/search_vulns](https://github.com/ra1nb0rn/search_vulns?tab=readme-ov-file)

This tool aggregates results from multiple vulnerability databases (NVD, ExploitDB, Vulners, and others) into a unified, deduplicated output. It is particularly useful when you need a broad overview of all known vulnerabilities for a given product without manually checking each database separately.

```bash
# Install
git clone https://github.com/ra1nb0rn/search_vulns.git
cd search_vulns && pip install -r requirements.txt

# Search
python search_vulns.py -q "OpenSSH 7.2"
```
---
## 📊 Dashboard & Visualization

### Nmap DID WHAT? — Nmap → Grafana Dashboard

> **Source:** [hackertarget/nmap-did-what](https://github.com/hackertarget/nmap-did-what) · **License:** GPL-2.0 · **Language:** Python 3

A lightweight two-part tool by [HackerTarget](https://hackertarget.com/) that turns raw Nmap XML scan results into a visual, interactive **Grafana** dashboard. It consists of a zero-dependency Python parser that loads scan data into SQLite, and a pre-configured Grafana Docker container with 13 ready-made visualization panels — no manual dashboard building required.

**How it works:**

```
┌──────────────┐       -oX        ┌───────────────────┐       SQLite        ┌──────────────────┐
│     Nmap     │ ──────────────▶  │ nmap-to-sqlite.py │ ────────────────▶  │  Grafana Docker  │
│   (scanner)  │   XML output     │  (Python parser)  │   nmap_results.db │   (Dashboard)    │
└──────────────┘                   └───────────────────┘                    └──────────────────┘
```

**What it parses from Nmap XML:**

| Data Point | Source |
|---|---|
| Host IPs & hostnames | `<address>` / `<hostnames>` elements |
| OS fingerprinting | `<osmatch>` elements, fallback to `service_ostype` |
| Port states (open/closed/filtered) | `<port state="...">` per host |
| Service name, product, version | `<service>` elements (requires `-sV`) |
| HTTP page titles | Nmap `http-title` script output (requires `-sC`) |
| SSL certificate CN & issuer | Nmap `ssl-cert` script output (requires `-sC`) |
| Scan metadata | Nmap version, command line, timestamps, elapsed time |

**Dashboard panels (13 total):**

| Panel | Type | What It Shows |
|---|---|---|
| Hosts Up | Stat | Total live hosts discovered |
| Open Ports | Stat | Total open ports across all hosts |
| Unique Ports | Stat | Distinct port numbers found open |
| Scans | Stat | Total scans loaded into the database |
| Operating Systems | Pie Chart | OS distribution across discovered hosts |
| Unidentified Services | Pie Chart | Open ports with unknown services |
| Open Ports Found | Bar Chart | Ports ranked by frequency |
| Live Hosts & Open Ports over Time | Time Series | Scan trends across multiple runs |
| Port Tested Per Second | Bar Gauge | Scan performance per host |
| Identified Services | Table | Service name, product, version details |
| Open Services | Table | All open ports with service info |
| Hosts | Table | Per-host breakdown with OS and port counts |
| Scans Loaded | Table | Metadata for every imported scan |

**Setup:**

```bash
# 1. Clone
git clone https://github.com/hackertarget/nmap-did-what.git
cd nmap-did-what

# 2. Run your Nmap scan with XML output
nmap -sV -sC -O -oX scan_results.xml <target>

# 3. Parse XML into SQLite (zero external Python dependencies)
cd data/
python nmap-to-sqlite.py scan_results.xml
# → Creates data/nmap_results.db

# 4. Launch Grafana dashboard via Docker
cd ../grafana-docker/
docker-compose up -d
```

Open `http://localhost:3000` — login `admin`/`admin`. The dashboard is auto-provisioned with all 13 panels.

**Multiple scans accumulate** in the same SQLite database over time, so Grafana's time-range filters let you compare trends across scan runs — perfect for tracking how a network's attack surface evolves between assessments.

> **Tutorial:** [Nmap Dashboard with Grafana](https://hackertarget.com/nmap-dashboard-with-grafana/) — HackerTarget's full written walkthrough with screenshots.
---

## 📄 Reporting & Notifications

### HTML Report Generation

Scan results are transformed into polished, interactive HTML reports that can be shared with stakeholders or archived for compliance purposes. The reports include:

- Executive summary with total hosts, open ports, and severity distribution
- Per-host detailed findings with service banners and detected vulnerabilities
- CVE reference links with CVSS scores and exploit availability indicators
- Sortable and filterable tables for efficient triage

### Graphviz Network Graphs

> **Source:** [vdjagilev/nmap-formatter](https://github.com/vdjagilev/nmap-formatter?tab=readme-ov-file)

Using nmap-formatter, raw Nmap XML output is converted into Graphviz DOT files that can be rendered as network topology diagrams. These visualizations make it immediately clear which hosts are interconnected, which services are exposed, and how vulnerabilities cluster across the target network.

```bash
# Generate graph
python visualize/nmap-formatter/graphize.py -i scan_output.xml -o topology.dot
dot -Tpng topology.dot -o topology.png
```

### Telegram Bot Notifications

> **Inspired by:** [queencitycyber/nucleiUI](https://github.com/queencitycyber/nucleiUI)

Critical findings are pushed to a Telegram bot in real time, ensuring that security teams are alerted the moment a high-severity vulnerability is discovered. The notification includes the target host, affected service, CVE identifiers, CVSS scores, and direct links to the full report.

**Configuration:**

```yaml
# nmap_presets.yaml
telegram:
  bot_token: "YOUR_BOT_TOKEN"
  chat_id: "YOUR_CHAT_ID"
  severity_threshold: "high"     # Only notify for high/critical
  include_cve_links: true
  report_base_url: "https://your-dashboard.example.com/reports/"
```

---

<div align="center">

**Built with 🔥 by @0xbugatti & the security community — for the security community.**

<br><br>

<a href="https://github.com/0xbugatti">
  <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24"><circle cx="12" cy="12" r="11" fill="#24292e"/><path fill="#FFFFFF" d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/></svg>
</a>&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://x.com/0xbugatti">
  <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24"><path fill="#1as1F2" d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
</a>&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://linkedin.com/in/0xbugatti">
  <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24"><path fill="#0A66C2" d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
</a>&nbsp;&nbsp;&nbsp;&nbsp;


</div>
