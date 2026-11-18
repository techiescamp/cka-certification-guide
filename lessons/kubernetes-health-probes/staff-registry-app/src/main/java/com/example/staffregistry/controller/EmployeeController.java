package com.example.staffregistry.controller;

import com.example.staffregistry.service.EmployeeService;
import com.example.staffregistry.service.DatabaseConnectionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
public class EmployeeController {

    private static final Logger logger = LoggerFactory.getLogger(EmployeeController.class);

    private final EmployeeService employeeService;
    private final DatabaseConnectionService databaseConnectionService;

    @Autowired
    public EmployeeController(EmployeeService employeeService,
                           DatabaseConnectionService databaseConnectionService) {
        this.employeeService = employeeService;
        this.databaseConnectionService = databaseConnectionService;
    }

    // JSON API for Live Dashboard Polling
    @GetMapping(value = "/api/dashboard/status", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> getDashboardStatus() {
        return Map.of(
            "databaseConnected", databaseConnectionService.isDatabaseConnected(),
            "employeeCount", employeeService.count(),
            "logs", databaseConnectionService.getConnectionLogs()
        );
    }

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    public String home() {
        List<Map<String, String>> employees = employeeService.getAll();

        StringBuilder recordRows = new StringBuilder();
        if (employees.isEmpty()) {
            recordRows.append("<tr><td colspan='5' class='empty'>No employees registered yet.</td></tr>");
        } else {
            for (Map<String, String> e : employees) {
                String mode = esc(e.get("workMode"));
                String modeClass = "badge-default";
                if ("Remote".equalsIgnoreCase(mode)) modeClass = "badge-remote";
                else if ("Hybrid".equalsIgnoreCase(mode)) modeClass = "badge-hybrid";
                else if ("On-site".equalsIgnoreCase(mode)) modeClass = "badge-onsite";

                recordRows.append("<tr>")
                    .append("<td><div class='dev-name'>").append(esc(e.get("name"))).append("</div><div class='dev-title'>").append(esc(e.get("jobTitle"))).append("</div></td>")
                    .append("<td><span class='badge ").append(modeClass).append("'>").append(mode).append("</span></td>")
                    .append("<td><code class='tech-pill'>").append(esc(e.get("primarySkill"))).append("</code></td>")
                    .append("<td>").append(esc(e.get("officeLocation"))).append("</td>")
                    .append("<td><a href='mailto:").append(esc(e.get("corporateEmail"))).append("' class='mail-link'>").append(esc(e.get("corporateEmail"))).append("</a></td>")
                    .append("</tr>");
            }
        }

        String topHtml = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Staff Registry</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500;600&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
                <style>
                    * { box-sizing: border-box; margin: 0; padding: 0; }
                    body {
                        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                        background: radial-gradient(circle at 50% 0%, #12141d 0%, #08090d 60%, #030305 100%);
                        color: #cbd5e1;
                        min-height: 100vh;
                        overflow-x: hidden;
                    }
                    ::-webkit-scrollbar { width: 8px; }
                    ::-webkit-scrollbar-track { background: #08090d; }
                    ::-webkit-scrollbar-thumb { background: #1e293b; border-radius: 4px; }
                    ::-webkit-scrollbar-thumb:hover { background: #334155; }

                    /* Nav */
                    nav {
                        display: grid;
                        grid-template-columns: 1fr auto 1fr;
                        align-items: center;
                        padding: 1rem 3rem;
                        position: sticky;
                        top: 0;
                        background: rgba(8, 9, 13, 0.85);
                        backdrop-filter: blur(12px);
                        -webkit-backdrop-filter: blur(12px);
                        border-bottom: 1px solid rgba(255,255,255,0.05);
                        z-index: 100;
                    }
                    .nav-brand {
                        font-family: 'Fira Code', monospace;
                        font-weight: 600;
                        font-size: 1.05rem;
                        color: #00f2fe;
                        text-decoration: none;
                        display: flex;
                        align-items: center;
                    }
                    .nav-brand span { color: #fff; }
                    .nav-links {
                        display: flex;
                        gap: 0.25rem;
                        background: rgba(255,255,255,0.03);
                        border: 1px solid rgba(255,255,255,0.06);
                        border-radius: 9999px;
                        padding: 0.25rem 0.4rem;
                    }
                    .nav-links button {
                        color: #94a3b8;
                        background: none;
                        border: none;
                        padding: 0.4rem 1.1rem;
                        border-radius: 9999px;
                        font-size: 0.82rem;
                        font-weight: 500;
                        cursor: pointer;
                        transition: all 0.2s ease;
                        font-family: inherit;
                    }
                    .nav-links button.active, .nav-links button:hover { color: #fff; background: rgba(255,255,255,0.08); }
                    .nav-cta {
                        justify-self: end;
                        background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
                        color: #030405;
                        font-weight: 700;
                        font-size: 0.82rem;
                        padding: 0.5rem 1.2rem;
                        border-radius: 9999px;
                        border: none;
                        cursor: pointer;
                        box-shadow: 0 0 15px rgba(0,242,254,0.2);
                        transition: all 0.2s;
                        font-family: inherit;
                        white-space: nowrap;
                    }
                    .nav-cta:hover { transform: translateY(-1px); box-shadow: 0 0 25px rgba(0,242,254,0.4); }

                    /* Hero */
                    .hero {
                        text-align: center;
                        padding: 7rem 1rem 5rem;
                    }
                    .hero-title {
                        font-size: 3.2rem;
                        font-weight: 800;
                        color: #f8fafc;
                        line-height: 1.15;
                        margin-bottom: 1rem;
                    }
                    .hero-title .accent { color: #00f2fe; }
                    .hero-sub {
                        font-size: 1rem;
                        color: #64748b;
                        max-width: 480px;
                        margin: 0 auto 2.5rem;
                        line-height: 1.7;
                    }
                    .hero-btn {
                        background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
                        color: #030405;
                        font-weight: 700;
                        font-size: 0.95rem;
                        padding: 0.9rem 2.4rem;
                        border-radius: 9999px;
                        border: none;
                        cursor: pointer;
                        box-shadow: 0 0 20px rgba(0,242,254,0.25);
                        transition: all 0.2s;
                        font-family: inherit;
                    }
                    .hero-btn:hover { transform: translateY(-2px); box-shadow: 0 0 35px rgba(0,242,254,0.4); }

                    /* Modal overlay */
                    .modal-overlay {
                        display: none;
                        position: fixed;
                        inset: 0;
                        background: rgba(0,0,0,0.75);
                        backdrop-filter: blur(4px);
                        -webkit-backdrop-filter: blur(4px);
                        z-index: 200;
                        align-items: center;
                        justify-content: center;
                        padding: 1.5rem;
                    }
                    .modal-overlay.open { display: flex; }

                    /* Modal box */
                    .modal {
                        background: #0d1117;
                        border: 1px solid rgba(255,255,255,0.08);
                        border-radius: 16px;
                        box-shadow: 0 30px 80px rgba(0,0,0,0.7), 0 0 0 1px rgba(0,242,254,0.05);
                        width: 100%;
                        max-height: 90vh;
                        overflow-y: auto;
                        animation: modal-in 0.2s ease;
                    }
                    .modal-sm { max-width: 520px; }
                    .modal-lg { max-width: 980px; }
                    @keyframes modal-in {
                        from { opacity: 0; transform: translateY(16px) scale(0.97); }
                        to   { opacity: 1; transform: translateY(0) scale(1); }
                    }
                    .modal-header {
                        padding: 1.25rem 1.5rem;
                        border-bottom: 1px solid rgba(255,255,255,0.05);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        position: sticky;
                        top: 0;
                        background: #0d1117;
                        z-index: 1;
                    }
                    .modal-title {
                        font-family: 'Fira Code', monospace;
                        font-size: 0.9rem;
                        font-weight: 700;
                        color: #f8fafc;
                    }
                    .modal-close {
                        background: rgba(255,255,255,0.04);
                        border: 1px solid rgba(255,255,255,0.08);
                        color: #94a3b8;
                        width: 30px;
                        height: 30px;
                        border-radius: 6px;
                        cursor: pointer;
                        font-size: 1rem;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all 0.15s;
                    }
                    .modal-close:hover { color: #fff; background: rgba(255,255,255,0.08); }
                    .modal-body { padding: 1.5rem; }

                    /* Table */
                    table { width: 100%; border-collapse: collapse; text-align: left; }
                    th {
                        font-size: 0.68rem;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: #475569;
                        padding: 0.75rem 1rem;
                        border-bottom: 1px solid rgba(255,255,255,0.06);
                        font-family: 'Fira Code', monospace;
                    }
                    td {
                        padding: 0.85rem 1rem;
                        font-size: 0.82rem;
                        border-bottom: 1px solid rgba(255,255,255,0.03);
                        color: #cbd5e1;
                    }
                    tr:hover td { background: rgba(255,255,255,0.01); }
                    tr:last-child td { border-bottom: none; }
                    .badge {
                        padding: 0.2rem 0.55rem;
                        border-radius: 9999px;
                        font-size: 0.68rem;
                        font-weight: 600;
                        text-transform: uppercase;
                        display: inline-block;
                    }
                    .badge-remote { background: rgba(16,185,129,0.08); color: #34d399; border: 1px solid rgba(16,185,129,0.15); }
                    .badge-hybrid { background: rgba(245,158,11,0.08); color: #fbbf24; border: 1px solid rgba(245,158,11,0.15); }
                    .badge-onsite { background: rgba(59,130,246,0.08); color: #60a5fa; border: 1px solid rgba(59,130,246,0.15); }
                    .badge-default { background: rgba(148,163,184,0.08); color: #94a3b8; border: 1px solid rgba(148,163,184,0.15); }
                    .tech-pill {
                        font-family: 'Fira Code', monospace;
                        color: #a5f3fc;
                        background: rgba(6,182,212,0.06);
                        padding: 0.1rem 0.35rem;
                        border-radius: 4px;
                        border: 1px solid rgba(6,182,212,0.15);
                        font-size: 0.78rem;
                    }
                    .dev-name { font-weight: 600; color: #f8fafc; }
                    .dev-title { font-size: 0.72rem; color: #64748b; margin-top: 0.1rem; }
                    .mail-link { color: #38bdf8; text-decoration: none; }
                    .mail-link:hover { text-decoration: underline; color: #00f2fe; }
                    .empty { color: #64748b; text-align: center; padding: 3rem 0 !important; font-style: italic; }

                    /* Form */
                    .field { display: flex; flex-direction: column; gap: 0.35rem; margin-bottom: 1rem; }
                    .field label { font-size: 0.68rem; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.08em; }
                    .field input, .field select {
                        background: rgba(255,255,255,0.02);
                        border: 1px solid rgba(255,255,255,0.06);
                        border-radius: 8px;
                        padding: 0.55rem 0.85rem;
                        font-size: 0.82rem;
                        color: #f8fafc;
                        outline: none;
                        transition: all 0.15s;
                        font-family: inherit;
                    }
                    .field input:focus, .field select:focus {
                        border-color: #00f2fe;
                        background: rgba(255,255,255,0.04);
                        box-shadow: 0 0 8px rgba(0,242,254,0.15);
                    }
                    .field input::placeholder { color: #475569; }
                    .combo { position: relative; }
                    .combo input { width: 100%; }
                    .combo-list {
                        display: none;
                        position: absolute;
                        top: calc(100% + 4px);
                        left: 0;
                        right: 0;
                        z-index: 20;
                        max-height: 190px;
                        overflow-y: auto;
                        list-style: none;
                        margin: 0;
                        padding: 0.3rem;
                        background: #0d1117;
                        border: 1px solid rgba(0,242,254,0.25);
                        border-radius: 8px;
                        box-shadow: 0 12px 30px rgba(0,0,0,0.6);
                    }
                    .combo-list.open { display: block; }
                    .combo-list li {
                        padding: 0.45rem 0.65rem;
                        font-size: 0.8rem;
                        color: #cbd5e1;
                        border-radius: 6px;
                        cursor: pointer;
                    }
                    .combo-list li.active, .combo-list li:hover { background: rgba(0,242,254,0.12); color: #fff; }
                    .combo-list li.group { color: #64748b; font-size: 0.62rem; text-transform: uppercase; letter-spacing: 0.08em; cursor: default; padding-top: 0.5rem; }
                    .combo-list li.group:hover { background: none; color: #64748b; }
                    .field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
                    .radio-group { display: flex; gap: 1rem; padding: 0.4rem 0; }
                    .radio-group label { display: flex; align-items: center; gap: 0.3rem; font-size: 0.8rem; color: #cbd5e1; cursor: pointer; text-transform: none; letter-spacing: normal; }
                    .radio-group input[type=radio] { accent-color: #00f2fe; width: 14px; height: 14px; cursor: pointer; }
                    .submit-btn {
                        width: 100%;
                        margin-top: 0.5rem;
                        background: linear-gradient(135deg, #00f2fe 0%, #4facfe 100%);
                        color: #030405;
                        border: none;
                        border-radius: 8px;
                        padding: 0.7rem;
                        font-size: 0.85rem;
                        font-weight: 700;
                        cursor: pointer;
                        transition: all 0.2s;
                        font-family: inherit;
                        box-shadow: 0 0 15px rgba(0,242,254,0.15);
                    }
                    .submit-btn:hover { transform: translateY(-1px); box-shadow: 0 0 20px rgba(0,242,254,0.3); }

                    @media(max-width: 640px) {
                        nav { padding: 1rem 1.2rem; }
                        .hero-title { font-size: 2.1rem; }
                        .field-row { grid-template-columns: 1fr; }
                        .modal-lg { max-width: 100%; }
                    }
                </style>
            </head>
            <body>

            <nav>
                <a href="/" class="nav-brand">&lt;Staff<span>Registry</span> /&gt;</a>
                <div class="nav-links">
                    <button class="active" onclick="void(0)">Home</button>
                    <button onclick="openModal('onboard-modal')">Add Employee</button>
                    <button onclick="openModal('engineers-modal')">Directory</button>
                </div>
                <button class="nav-cta" onclick="openModal('onboard-modal')">Add Employee</button>
            </nav>

            <div class="hero">
                <h1 class="hero-title">Staff Registry &amp;<br><span class="accent">Team</span> Directory</h1>
                <p class="hero-sub">Add new hires, keep every profile up to date, and find anyone by role, skill or office. One source of truth for your whole organization.</p>
                <button class="hero-btn" onclick="openModal('onboard-modal')">Add Employee &rarr;</button>
            </div>

            <!-- Onboard Modal -->
            <div class="modal-overlay" id="onboard-modal" onclick="overlayClose(event, 'onboard-modal')">
                <div class="modal modal-sm">
                    <div class="modal-header">
                        <div class="modal-title">Add New Employee</div>
                        <button class="modal-close" onclick="closeModal('onboard-modal')">&#x2715;</button>
                    </div>
                    <div class="modal-body">
                        <form method="POST" action="/submit">
                            <div class="field">
                                <label>Full Name</label>
                                <input type="text" name="name" placeholder="Full name" required />
                            </div>
                            <div class="field-row">
                                <div class="field">
                                    <label>Work Mode</label>
                                    <div class="radio-group">
                                        <label><input type="radio" name="workMode" value="Remote" required /> Remote</label>
                                        <label><input type="radio" name="workMode" value="Hybrid" /> Hybrid</label>
                                    </div>
                                </div>
                                <div class="field">
                                    <label>Years of Experience</label>
                                    <input type="number" name="yearsOfExperience" placeholder="0" min="0" required />
                                </div>
                            </div>
                            <div class="field-row">
                                <div class="field">
                                    <label>Hire Date</label>
                                    <input type="date" name="hireDate" required />
                                </div>
                                <div class="field">
                                    <label>Primary Skill</label>
                                    <div class="combo">
                                        <input type="text" name="primarySkill" id="skill-input" placeholder="e.g. Java, Sales, Design" autocomplete="off" required />
                                        <ul class="combo-list" id="skill-list" role="listbox"></ul>
                                    </div>
                                </div>
                            </div>
                            <div class="field-row">
                                <div class="field">
                                    <label>Slack Handle</label>
                                    <input type="text" name="slackUsername" placeholder="@handle" />
                                </div>
                                <div class="field">
                                    <label>Work Email</label>
                                    <input type="email" name="corporateEmail" placeholder="employee@corp.com" required />
                                </div>
                            </div>
                            <div class="field-row">
                                <div class="field">
                                    <label>Office</label>
                                    <input type="text" name="officeLocation" placeholder="Office location" required />
                                </div>
                                <div class="field">
                                    <label>Job Title</label>
                                    <select name="jobTitle" required>
                                        <option value="">Select Role</option>
                                        <optgroup label="Engineering">
                                            <option>Junior Software Engineer</option>
                                            <option>Software Engineer</option>
                                            <option>Senior Software Engineer</option>
                                            <option>Staff Engineer</option>
                                        </optgroup>
                                        <optgroup label="AI &amp; Machine Learning">
                                            <option>Machine Learning Engineer</option>
                                            <option>AI Engineer</option>
                                            <option>Data Scientist</option>
                                            <option>Research Scientist</option>
                                            <option>MLOps Engineer</option>
                                            <option>Prompt Engineer</option>
                                            <option>Data Engineer</option>
                                            <option>AI Product Manager</option>
                                        </optgroup>
                                        <optgroup label="Operations &amp; DevOps">
                                            <option>SRE / DevOps Engineer</option>
                                            <option>Cloud Infrastructure Architect</option>
                                        </optgroup>
                                        <optgroup label="Product &amp; Design">
                                            <option>Product Manager</option>
                                            <option>UX / UI Designer</option>
                                        </optgroup>
                                        <optgroup label="Business &amp; People">
                                            <option>Sales Executive</option>
                                            <option>HR Manager</option>
                                            <option>Operations Manager</option>
                                        </optgroup>
                                    </select>
                                </div>
                            </div>
                            <button type="submit" class="submit-btn">Add Employee &rarr;</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Engineers Modal -->
            <div class="modal-overlay" id="engineers-modal" onclick="overlayClose(event, 'engineers-modal')">
                <div class="modal modal-lg">
                    <div class="modal-header">
                        <div class="modal-title">Employee Directory</div>
                        <button class="modal-close" onclick="closeModal('engineers-modal')">&#x2715;</button>
                    </div>
                    <div class="modal-body" style="padding:0;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Employee / Role</th>
                                    <th>Work Mode</th>
                                    <th>Primary Skill</th>
                                    <th>Office</th>
                                    <th>Email</th>
                                </tr>
                            </thead>
                            <tbody>
                                """ + recordRows.toString() + """
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <script>
                function openModal(id) {
                    document.getElementById(id).classList.add('open');
                    document.body.style.overflow = 'hidden';
                }
                function closeModal(id) {
                    document.getElementById(id).classList.remove('open');
                    document.body.style.overflow = '';
                }
                function overlayClose(e, id) {
                    if (e.target === e.currentTarget) closeModal(id);
                }
                document.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape') {
                        document.querySelectorAll('.modal-overlay.open').forEach(function(m) {
                            closeModal(m.id);
                        });
                    }
                });
                // Primary skill combobox (free text + grouped suggestions)
                (function () {
                    var SKILLS = [
                        ['AI & Machine Learning', ['Machine Learning', 'Deep Learning', 'LLMs', 'Generative AI', 'Prompt Engineering', 'NLP', 'Computer Vision', 'Reinforcement Learning', 'PyTorch', 'TensorFlow', 'MLOps', 'RAG / Vector Databases']],
                        ['Data', ['Data Science', 'Data Engineering', 'SQL', 'PostgreSQL']],
                        ['Engineering', ['Java', 'Spring Boot', 'Golang', 'Python', 'Rust', 'TypeScript']],
                        ['Cloud & DevOps', ['Kubernetes', 'Docker']],
                        ['Business & Design', ['Sales', 'Product Management', 'UX Design', 'HR']]
                    ];
                    var input = document.getElementById('skill-input');
                    var list = document.getElementById('skill-list');
                    var active = -1;
                    function items() { return list.querySelectorAll('li.opt'); }
                    function render() {
                        var q = input.value.trim().toLowerCase();
                        list.innerHTML = '';
                        SKILLS.forEach(function (g) {
                            var hits = g[1].filter(function (n) { return n.toLowerCase().indexOf(q) !== -1; });
                            if (!hits.length) return;
                            var h = document.createElement('li');
                            h.className = 'group';
                            h.textContent = g[0];
                            list.appendChild(h);
                            hits.forEach(function (n) {
                                var li = document.createElement('li');
                                li.className = 'opt';
                                li.setAttribute('role', 'option');
                                li.textContent = n;
                                li.addEventListener('mousedown', function (e) { e.preventDefault(); pick(n); });
                                list.appendChild(li);
                            });
                        });
                        active = -1;
                        list.classList.toggle('open', list.children.length > 0);
                    }
                    function pick(v) { input.value = v; list.classList.remove('open'); }
                    function move(d) {
                        var els = items();
                        if (!els.length) return;
                        if (active >= 0) els[active].classList.remove('active');
                        active = (active + d + els.length) % els.length;
                        els[active].classList.add('active');
                        els[active].scrollIntoView({ block: 'nearest' });
                    }
                    input.addEventListener('input', render);
                    input.addEventListener('focus', render);
                    input.addEventListener('blur', function () { list.classList.remove('open'); });
                    input.addEventListener('keydown', function (e) {
                        if (e.key === 'ArrowDown') { e.preventDefault(); if (!list.classList.contains('open')) render(); move(1); }
                        else if (e.key === 'ArrowUp') { e.preventDefault(); move(-1); }
                        else if (e.key === 'Enter' && active >= 0) { e.preventDefault(); pick(items()[active].textContent); }
                        else if (e.key === 'Escape' && list.classList.contains('open')) { e.stopPropagation(); list.classList.remove('open'); }
                    });
                })();
                // Open the directory after a successful add
                const params = new URLSearchParams(window.location.search);
                if (params.get('registered') === '1') openModal('engineers-modal');
                if (params.get('error') === 'invalid') alert('Registration failed: please check the form values.');
                if (params.get('error') === 'unavailable') alert('Registration failed: database is not available. Try again shortly.');
            </script>
            </body>
            </html>
            """;

        return topHtml;
    }

    @PostMapping(value = "/submit", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    public ResponseEntity<Void> submit(
            @RequestParam(defaultValue = "") String name,
            @RequestParam(defaultValue = "") String workMode,
            @RequestParam(defaultValue = "") String yearsOfExperience,
            @RequestParam(defaultValue = "") String hireDate,
            @RequestParam(defaultValue = "") String officeLocation,
            @RequestParam(defaultValue = "") String primarySkill,
            @RequestParam(defaultValue = "") String slackUsername,
            @RequestParam(defaultValue = "") String corporateEmail,
            @RequestParam(defaultValue = "") String jobTitle) {
        String location = "/?registered=1";
        try {
            employeeService.save(name, workMode, yearsOfExperience, hireDate,
                    officeLocation, primarySkill, slackUsername, corporateEmail, jobTitle);
        } catch (IllegalArgumentException e) {
            logger.warn("Rejected employee submission: {}", e.getMessage());
            location = "/?error=invalid";
        } catch (Exception e) {
            logger.error("Could not save employee", e);
            location = "/?error=unavailable";
        }
        return ResponseEntity.status(HttpStatus.FOUND)
                .header(HttpHeaders.LOCATION, location)
                .build();
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
