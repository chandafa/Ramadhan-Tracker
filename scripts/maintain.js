const fs = require("fs");
const path = require("path");

const token = process.env.GITHUB_TOKEN;
const repoFullName = process.env.GITHUB_REPOSITORY || "chandafa/Ramadhan-Tracker";
const isDryRun = process.env.BOT_DRY_RUN === "true";
const maxIssues = Number(process.env.BOT_MAX_ISSUES || 3);

if (!repoFullName || !repoFullName.includes("/")) {
  throw new Error("GITHUB_REPOSITORY tidak valid.");
}

if (!token && !isDryRun) {
  throw new Error("GITHUB_TOKEN tidak ditemukan.");
}

const [owner, repo] = repoFullName.split("/");

const ROOT = process.cwd();
const INCLUDE_EXTENSIONS = new Set([
  ".dart",
  ".js",
  ".jsx",
  ".ts",
  ".tsx",
  ".json",
  ".yml",
  ".yaml",
  ".md",
  ".gradle",
  ".kt",
  ".java",
  ".xml",
  ".swift",
  ".m",
  ".h",
]);

const IGNORE_DIRS = new Set([
  ".git",
  ".dart_tool",
  ".github",
  "build",
  "dist",
  "node_modules",
  "ios/Pods",
  "vendor",
]);

function shouldIgnore(relativePath) {
  const normalized = relativePath.replaceAll("\\\\", "/");
  return [...IGNORE_DIRS].some((dir) => normalized === dir || normalized.startsWith(`${dir}/`));
}

function walk(dir, result = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    const relativePath = path.relative(ROOT, fullPath).replaceAll("\\\\", "/");

    if (shouldIgnore(relativePath)) {
      continue;
    }

    if (entry.isDirectory()) {
      walk(fullPath, result);
      continue;
    }

    if (!entry.isFile()) {
      continue;
    }

    const extension = path.extname(entry.name);
    if (INCLUDE_EXTENSIONS.has(extension) || entry.name === "Dockerfile") {
      result.push(relativePath);
    }
  }

  return result;
}

async function githubRequest(endpoint, options = {}) {
  const response = await fetch(`https://api.github.com${endpoint}`, {
    ...options,
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${token}`,
      "X-GitHub-Api-Version": "2022-11-28",
      ...(options.headers || {}),
    },
  });

  const text = await response.text();
  const data = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const message = data?.message || response.statusText;
    throw new Error(`GitHub API error ${response.status}: ${message}`);
  }

  return data;
}

async function issueExists(title) {
  const query = encodeURIComponent(`repo:${owner}/${repo} is:issue in:title "${title}"`);
  const data = await githubRequest(`/search/issues?q=${query}&per_page=1`);
  return data.total_count > 0;
}

async function createIssue(title, body) {
  if (isDryRun) {
    console.log(`[dry-run] would create issue: ${title}`);
    return;
  }

  if (await issueExists(title)) {
    console.log(`Issue sudah ada: ${title}`);
    return;
  }

  await githubRequest(`/repos/${owner}/${repo}/issues`, {
    method: "POST",
    body: JSON.stringify({
      title,
      body,
      labels: ["maintenance", "bot"],
    }),
  });

  console.log(`Issue dibuat: ${title}`);
}

function scanFiles(files) {
  const findings = [];

  for (const file of files) {
    let content = "";

    try {
      content = fs.readFileSync(path.join(ROOT, file), "utf8");
    } catch {
      continue;
    }

    const lines = content.split(/\r?\n/);

    lines.forEach((line, index) => {
      if (/\b(TODO|FIXME|HACK|XXX)\b/i.test(line)) {
        findings.push({
          file,
          line: index + 1,
          text: line.trim().slice(0, 180),
        });
      }
    });
  }

  return findings;
}

function buildReport(files, findings) {
  const now = new Date().toISOString();
  const report = [];

  report.push("# Maintenance Report");
  report.push("");
  report.push(`Last update: ${now}`);
  report.push(`Repository: ${owner}/${repo}`);
  report.push("");
  report.push("## Summary");
  report.push("");
  report.push(`- Files scanned: ${files.length}`);
  report.push(`- Maintenance notes found: ${findings.length}`);
  report.push("");

  if (findings.length === 0) {
    report.push("Tidak ada TODO/FIXME/HACK/XXX yang ditemukan. Clean, seperti niat sebelum buka YouTube.");
    report.push("");
    return report.join("\n");
  }

  report.push("## Findings");
  report.push("");

  for (const item of findings.slice(0, 50)) {
    report.push(`- \`${item.file}:${item.line}\` — ${item.text}`);
  }

  if (findings.length > 50) {
    report.push(`- ...dan ${findings.length - 50} temuan lainnya.`);
  }

  report.push("");
  report.push("## Next Steps");
  report.push("");
  report.push("- Review temuan yang penting.");
  report.push("- Ubah TODO menjadi issue kecil yang bisa dikerjakan bertahap.");
  report.push("- Merge PR bot kalau laporan sudah sesuai.");
  report.push("");

  return report.join("\n");
}

async function main() {
  const files = walk(ROOT);
  const findings = scanFiles(files);
  const report = buildReport(files, findings);

  fs.mkdirSync(path.join(ROOT, "docs"), { recursive: true });
  fs.writeFileSync(path.join(ROOT, "docs", "maintenance-report.md"), report);

  console.log(`Scanned ${files.length} files.`);
  console.log(`Found ${findings.length} maintenance notes.`);
  console.log("Maintenance report updated.");

  for (const item of findings.slice(0, maxIssues)) {
    const issueTitle = `Maintenance: ${item.file}:${item.line}`;
    const issueBody = [
      "Bot menemukan catatan maintenance di kode.",
      "",
      `File: \`${item.file}\``,
      `Line: \`${item.line}\``,
      "",
      "```txt",
      item.text,
      "```",
      "",
      "Tolong review apakah ini perlu diperbaiki, dihapus, atau dijadikan task lanjutan.",
    ].join("\n");

    await createIssue(issueTitle, issueBody);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
