import fs from 'node:fs';
import path from 'node:path';
import { themes } from '../themes';

let css = '';

for (const [themeName, theme] of Object.entries(themes)) {
  css += `[data-theme="${themeName}"] {\n`;

  for (const [token, value] of Object.entries(theme)) {
    css += `  --${token}: ${value};\n`;
  }

  css += '}\n\n';
}

const outputDir = path.resolve('./app/assets/generated');
const outputFile = path.join(outputDir, 'themes.css');

// створити папку, якщо її немає
fs.mkdirSync(outputDir, {
  recursive: true,
});

fs.writeFileSync(outputFile, css);