// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@kurkle/color"
import * as ChartModule from "chart.js"
import "chartjs-adapter-date-fns"
import Chartkick from "chartkick"

const { TimeSeriesScale, LinearScale, LineController, LineElement, PointElement, CategoryScale } = Chart

Chart.register(TimeSeriesScale, LinearScale, LineController, LineElement, PointElement, CategoryScale)

window.Chart = Chart
Chartkick.addAdapter(Chart)