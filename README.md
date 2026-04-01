<div align="center">

<img src="https://raw.githubusercontent.com/0xBugatti/AesomeNmap/refs/heads/main/.github/logo-light.svg" width="420" alt="Awesomenmap">

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
- [Dashboard & Visualization](#-dashboard--visualization)
- [Reporting & Notifications](#-reporting--notifications)

---

## 🎯 Overview

**Awesomenmap** is a knowledge-base repository that centralizes the most valuable Nmap NSE scripts, CVE search utilities, and post-scan reporting pipelines into a single, well-organized reference. Instead of hunting across dozens of GitHub repositories and forum posts, security practitioners can use this project as a definitive index and automation hub for all things Nmap.

The repository is intentionally kept lightweight — structured `README` files, shared resources, and upstream references. Third-party scripts are pulled from their original sources and kept up to date through a simple sync process.

| Capability | Description |
|---|---|
| **Script Management** | Pull and update the latest vulnerability, default-account, and version-detection NSE scripts from trusted upstream sources |
| **CVE Intelligence** | Search known CVEs and exploits directly from the command line without leaving your terminal |
| **Automated Scanning** | A dashboard-driven workflow assigns scanning targets, executes Nmap with the curated script set, and produces structured output |
| **Rich Reporting** | Generate HTML scan reports and Graphviz-compatible network topology graphs for every completed scan |
| **Real-time Alerts** | Push critical findings to a Telegram bot for instant visibility |

---

## 📂 Repository Structure

```
Awesomenmap/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── scripts/
│   ├── nse/                           # Curated NSE scripts
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
    ├── nmap-dashboard.xsl             # XSLT stylesheet for HTML reports
    └── nmap-formatter/                # Graphviz network topology generator
```

---

## 🔧 Core NSE Script Updates

These scripts form the backbone of the vulnerability detection workflow. Keep them up to date by pulling from their official upstream repositories.

### 1. Vulners — Vulnerability Detection

> **Source:** [vulnersCom/nmap-vulners](https://github.com/vulnersCom/nmap-vulners/blob/master/vulners.nse)

Queries the [Vulners.com](https://vulners.com/) API to match detected service versions against a comprehensive vulnerability database. Returns associated CVEs, CVSS scores, and available exploit references in real time.

```bash
cd scripts/nse/
git clone https://github.com/vulnersCom/nmap-vulners.git
cp nmap-vulners/vulners.nse ./
```

```bash
nmap -sV --script vulners.nse --script-args vulnersdebug=1 <target>
```

---

### 2. Default Accounts — Credential Auditing

> **Source:** [nnposter/nndefaccts](https://github.com/nnposter/nndefaccts)

Checks network services for default or well-known credentials using an extensive, regularly updated dictionary of default username/password pairs. Covers routers, cameras, IoT devices, industrial controllers, and enterprise software — invaluable during initial reconnaissance to identify services using factory-default authentication.

```bash
cd scripts/nse/
git clone https://github.com/nnposter/nndefaccts.git
cp nndefaccts/nndefaccts.nse ./
```

```bash
nmap -p 22,23,80,443,8080 --script nndefaccts.nse <target>
```

---

### 3. Vicarius Nmap — CVE Mapping

> **Source:** [VicariusInc/vicarius-nmap](https://github.com/VicariusInc/vicarius-nmap)

An alternative CVE mapping engine that cross-references detected software versions against the Vicarius vulnerability database. Complements the Vulners script by offering a second opinion on CVE coverage and surfacing discrepancies. Particularly strong for detecting known vulnerabilities in less common or niche software packages that may not receive immediate coverage in larger databases.

```bash
cd scripts/nse/
git clone https://github.com/VicariusInc/vicarius-nmap.git
cp -r vicarius-nmap/scripts/* ./
```

```bash
nmap -sV --script vicarius-cve <target>
```

---

## 🔄 Alternative: Vulscan Integration

> **Source:** [scipag/vulscan](https://github.com/scipag/vulscan?tab=readme-ov-file)

A self-contained, offline-capable alternative to the API-dependent Vulners script. Ships with local vulnerability databases and can be extended with custom CSV/JSON feeds. Performs version-string matching against its bundled databases, making it ideal for air-gapped environments or scans where internet access during execution is restricted or undesirable.

```bash
cd scripts/nse/
git clone https://github.com/scipag/vulscan.git
```

```bash
nmap -sV --script=vulscan/vulscan.nse <target>
```

> **Tip:** Use Vulners *and* Vulscan together for maximum coverage — Vulscan as the offline baseline and Vulners for real-time API enrichment.

---

## 📦 NSE Script Collections

Community-maintained collections that expand Nmap's detection capabilities beyond the official script library. Each has been vetted for quality and relevance — periodically pull the latest versions to stay current.

| Collection | Source | Focus |
|---|---|---|
| **nmap-extra-nse** | [sighook/nmap-extra-nse](https://github.com/sighook/nmap-extra-nse) | General-purpose auxiliary scripts not yet merged into the official Nmap distribution — custom service probes, brute-force modules, and recon helpers |
| **NSE_scripts** | [icarot/NSE_scripts](https://github.com/icarot/NSE_scripts/tree/master) | Vulnerability detection and information-gathering scripts tailored for web application auditing and service enumeration |
| **Custom-Nse** | [ibrahmsql/Custom-Nse](https://github.com/ibrahmsql/Custom-Nse) | Individually crafted NSE scripts targeting specific vulnerabilities, unusual protocols, and emerging threat landscapes |
| **log4shell_nse** | [righel/log4shell_nse](https://github.com/righel/log4shell_nse) | Dedicated Log4Shell (CVE-2021-44228) detector for Java-based services — performs both header-based and DNS-based verification |
| **ms-exchange-version** | [righel/ms-exchange-version-nse](https://github.com/righel/ms-exchange-version-nse) | Precise Microsoft Exchange Server version fingerprinting — essential for assessing Patch Tuesday compliance and ProxyShell/ProxyLogon exposure |
| **gitlab-version** | [righel/gitlab-version-nse](https://github.com/righel/gitlab-version-nse) | GitLab instance version detection with associated CVE identification — helps prioritize remediation for self-hosted DevOps infrastructure |
| **Official Nmap Scripts** | [nmap/nmap/scripts](https://github.com/nmap/nmap/tree/master/scripts) | The canonical upstream repository — always ensure your local scripts are at least as recent as this tree |

---

## 🔎 CVE Search CLI Tools

Command-line utilities to search for CVEs and exploits without leaving your terminal. They integrate into shell scripts, CI pipelines, and the Awesomenmap automation workflow.

### GetSploit — Vulners.com Exploit Finder

> **Source:** [vulnersCom/getsploit](https://github.com/vulnersCom/getsploit)

A lightweight Python CLI that queries the Vulners.com database for exploit code, shellcode, and proof-of-concept implementations. Returns direct links to exploit source code along with metadata such as publication date, exploit platform, and reliability rating.

```bash
pip install getsploit

getsploit -s "Apache Struts 2"
getsploit -s CVE-2021-44228
```

---

### search_vulns — Multi-Source CVE Search

> **Source:** [ra1nb0rn/search_vulns](https://github.com/ra1nb0rn/search_vulns?tab=readme-ov-file)

Aggregates results from multiple vulnerability databases (NVD, ExploitDB, Vulners, and others) into a unified, deduplicated output. Particularly useful when you need a broad overview of all known vulnerabilities for a given product without manually checking each database separately.

```bash
git clone https://github.com/ra1nb0rn/search_vulns.git
cd search_vulns && pip install -r requirements.txt

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

Scan results are transformed into polished, interactive HTML reports using the included XSLT stylesheet — shareable with stakeholders or archived for compliance purposes.

- Executive summary with total hosts, open ports, and severity distribution
- Per-host detailed findings with service banners and detected vulnerabilities
- CVE reference links with CVSS scores and exploit availability indicators
- Sortable and filterable tables for efficient triage

### Graphviz Network Graphs

> **Source:** [vdjagilev/nmap-formatter](https://github.com/vdjagilev/nmap-formatter?tab=readme-ov-file)

Raw Nmap XML output is converted into Graphviz DOT files that render as network topology diagrams — making it immediately clear which hosts are interconnected, which services are exposed, and how vulnerabilities cluster across the target network.

```bash
python visualize/nmap-formatter/graphize.py -i scan_output.xml -o topology.dot
dot -Tpng topology.dot -o topology.png
```

### Telegram Bot Notifications

```yaml
telegram:
  bot_token: "YOUR_BOT_TOKEN"
  chat_id: "YOUR_CHAT_ID"
  severity_threshold: "high"       # Only notify for high/critical
  include_cve_links: true
  report_base_url: "https://your-dashboard.example.com/reports/"
```

---

<div align="center">

**Built with 🔥 by [@0xBugatti](https://github.com/0xBugatti) & the security community — for the security community.**

<br><br>

<a href="https://github.com/0xBugatti"><img src="https://cdn.simpleicons.org/github/e6edf3" width="38" alt="GitHub" /></a>&nbsp;
<a href="https://twitter.com/0xbugatti"><img src="https://cdn.simpleicons.org/x/1DA1F2" width="38" alt="X" /></a>&nbsp;
<a href="https://linkedin.com/in/0xbugatti"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/linkedin/linkedin-original.svg" width="38" height="24" alt="LinkedIn" /></a>

</div>
