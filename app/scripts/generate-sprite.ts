import fs from 'node:fs';
import path from 'node:path';
import SVGSpriter from 'svg-sprite';

const spriter = new SVGSpriter({
  mode: {
    symbol: {
      dest: '.',
      sprite: 'sprite.svg',
    },
  },
});

const iconsDir = path.resolve('./app/assets/icons');
const outputFile = path.resolve('./public/sprite.svg');

for (const file of fs.readdirSync(iconsDir, { withFileTypes: true })) {
  if (!file.isFile() || !file.name.endsWith('.svg')) continue;

  const filePath = path.join(iconsDir, file.name);
  const svg = fs.readFileSync(filePath, 'utf-8');
  spriter.add(filePath, file.name, svg);
}

spriter.compile((error, result) => {
  if (error) {
    throw error;
  }

  const sprite = result?.symbol?.sprite;
  if (!sprite?.contents) {
    throw new Error('SVG sprite was not generated.');
  }

  fs.writeFileSync(outputFile, sprite.contents);
});