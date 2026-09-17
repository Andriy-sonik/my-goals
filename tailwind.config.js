/** @type {import('tailwindcss').Config} */
export default {
  content: [],
  theme: {
    extend: {
      colors: {
        primary: 'var(--primary)',
        sky: {
          300: 'var(--primaryHover)',
          400: 'var(--primary)',
          500: 'var(--primary)',
        },
      },
    },
  },
  plugins: [],
}

