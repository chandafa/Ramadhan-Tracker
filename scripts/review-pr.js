const fs = require("fs");

const token = process.env.GITHUB_TOKEN;
const repoFullName = process.env.GITHUB_REPOSITORY || "chandafa/Ramadhan-Tracker";
const eventPath = process.env.GITHUB_EVENT_PATH;

if (!token) {
  throw new Error("GITHUB_TOKEN tidak ditemukan.");
}

if (!repoFullName || !repoFullName.includes("/")) {
  throw new Error("GITHUB_REPOSITORY tidak valid.");
}

if (!eventPath) {
  throw new Error("GITHUB_EVENT_PATH tidak ditemukan. Script ini hanya berjalan di GitHub Actions.");
}

const event = JSON.parse(fs.readFileSync(eventPath, "utf8"));
const pullNumber = event.pull_request?.number;

if (!pullNumber) {
  throw new Error("Pull request number tidak ditemukan.");
}

const [owner, repo] = repoFullName.split("/");

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

async function listPullRequestFiles() {
  const files = [];
  let page = 1;

  while (true) {
    const data = await githubRequest(`/repos/${owner}/${repo}/pulls/${pullNumber}/files?per_page=100&page=${page}`);
    files.push(...data);

    if (data.length < 100) {
      break;
    }

    page += 1;
  }

  return files;
}

function analyzeFile(file) {
  const notes = [];
  const patch = file.patch || "";
  const filename = file.filename || "";

  if (/\.env(\.|$)/i.test(filename) || filename.endsWith(".env")) {
    notes.push("File environment tersentuh. Pastikan tidak ada secret, API key, token, atau credential yang ikut masuk.");
  }

  if (file.changes > 500) {
    notes.push("Perubahan file cukup besar. Pertimbangkan pecah PR supaya review lebih mudah.");
  }

  if (/console\.log\(/.test(patch)) {
    notes.push("Ada `console.log`. Pastikan ini tidak tertinggal di production.");
  }

  if (/\b(TODO|FIXME|HACK|XXX)\b/i.test(patch)) {
    notes.push("Ada TODO/FIXME/HACK/XXX baru. Lebih aman dibuat issue agar tidak hilang.");
  }

  if (/password|secret|api[_-]?key|token/i.test(patch)) {
    notes.push("Patch mengandung kata sensitif seperti password/secret/api key/token. Review manual wajib sebelum merge.");
  }

  if (filename.endsWith("pubspec.yaml")) {
    notes.push("`pubspec.yaml` berubah. Pastikan dependency aman dan jalankan `flutter pub get` lalu test build.");
  }

  if (filename.includes("android/app/build.gradle") || filename.includes("android/app/build.gradle.kts")) {
    notes.push("Konfigurasi build Android berubah. Pastikan versionCode/versionName dan signing config masih benar.");
  }

  if (filename.includes("AndroidManifest.xml")) {
    notes.push("AndroidManifest berubah. Pastikan permission sesuai kebutuhan dan aman untuk Play Store.");
  }

  return notes;
}

async function main() {
  const files = await listPullRequestFiles();
  const reviewNotes = [];

  for (const file of files) {
    const notes = analyzeFile(file);

    for (const note of notes) {
      reviewNotes.push(`- \`${file.filename}\`: ${note}`);
    }
  }

  const body = [
    "## Automated Code Review",
    "",
    `Bot mengecek ${files.length} file yang berubah di PR ini.`,
    "",
    reviewNotes.length > 0 ? "### Catatan" : "### Hasil",
    "",
    reviewNotes.length > 0
      ? reviewNotes.join("\n")
      : "Tidak ada catatan besar dari pengecekan otomatis. Tetap lakukan human review sebelum merge.",
    "",
    "---",
    "Review ini otomatis, jadi jangan dipercaya 100%. Bot juga kadang sok senior.",
  ].join("\n");

  await githubRequest(`/repos/${owner}/${repo}/pulls/${pullNumber}/reviews`, {
    method: "POST",
    body: JSON.stringify({
      event: "COMMENT",
      body,
    }),
  });

  console.log("Review comment created.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
