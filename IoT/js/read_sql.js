// 基于准备好的dom，初始化echarts实例
// 请求的网址
// 示例接口，实际无数据，需自行实现
// var my_data = fetch('https://stevenhou.xyz/student09/api/dynamic-datas')
var temperatures = []

var myChart = echarts.init(document.getElementById('main'));

// 指定图表的配置项和数据
var option = {
  title: {
    text: '折线图示例'
  },
  tooltip: {},
  legend: {
    data: ['温度']
  },
  xAxis: {
    type: 'time'
  },
  yAxis: {
    type: 'value'
  },
}
myChart.setOption(option);


setInterval(function () {
  temperatures = []
  fetch('https://stevenhou.xyz/student09/api/dynamic-datas')
  //fetch('http://127.0.0.1:5009/dynamic-datas', {method: 'get', mode: 'no-cors'})
    // 本次回调，收到response后提取json数据
    .then(response => response.json())
    // 本次回调，提取到json数据后进行打印
    .then(data => {
      data.map(d => temperatures.push([d["time"],d["temperature"]]));
      console.log(temperatures);
      myChart.setOption({
      series: [
        { type: 'line',
          data: temperatures}
      ]
      });
    })
},10000);


