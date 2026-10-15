/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'blinkit-green': '#0C831F',
        'blinkit-yellow': '#F8CB46',
      }
    },
  },
  plugins: [],
}
