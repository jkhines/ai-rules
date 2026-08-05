#!/usr/bin/env node
// Claude Code statusLine command. Reads the JSON payload Claude Code sends on
// stdin (https://code.claude.com/docs/en/statusline.md) and prints:
// model | directory | context usage bar

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const model = data.model?.display_name || 'Claude';
    const dir = data.workspace?.current_dir?.split('/').pop() || '';
    const used = data.context_window?.used_percentage;

    let ctx = '';
    if (used != null) {
      const filled = Math.round(used / 10);
      const bar = '█'.repeat(filled) + '░'.repeat(10 - filled);
      const color = used < 50 ? 32 : used < 65 ? 33 : used < 80 ? 208 : 31;
      ctx = ` \x1b[38;5;${color}m${bar} ${used}%\x1b[0m`;
    }

    process.stdout.write(`\x1b[2m${model}\x1b[0m │ \x1b[2m${dir}\x1b[0m${ctx}`);
  } catch (e) {
    // Silent fail - don't break the statusline on a malformed payload.
  }
});
