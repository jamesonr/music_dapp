//auto script for adding products

Eutil = require('ethereumjs-util');
EcommerceStore = artifacts.require("./EcommerceStore.sol");
module.exports = function(callback) {
 current_time = Math.round(new Date() / 1000);
 amt_1 = web3.toWei(1, 'ether');
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('We Will Rock You', 'Queen', 'QmQJn7ipgu3rkJF546yP6FLsi17RpB9J7GaMDPDQecaRkx', 'QmSGfNEppU5xSbwdV82AiTscXRabfotPPt5GzB8BnNBMz2', current_time, current_time + 200, 2*amt_1, 0).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('Stairway To Heaven', 'Led Zepplin', 'QmV1k7mHvJyEnJveefLSoztp4GndYoWnNjT72JtjFghoFm', 'QmVvs5PFcY4q7ca8f2RqYSFoJLSEwcicgEWNM4J5oXtzij', current_time, current_time + 400, 3*amt_1, 1).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('This is War', '30 Seconds To Mars', 'QmarngZjA3cmCS7b5nefmqq1vXG544HgfGtfsUjeRN9DWj', 'QmX93gWdHpCEhwuL66pJ8htTuHmW51dakxvfgU9vj4VABE', current_time, current_time + 14, amt_1, 0).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('Ready Or Not', 'Fugees', 'QmWqkvPGcbVMUcmM61gph6BkQfustj1T8CKNNPUfoiVhgc', 'QmWpXgCnhStYnoFAi4bNXeVAqpGf8HkQ84n3YAW15xzqk6', current_time, current_time + 86400, 4*amt_1, 1).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('Video Killed The Radio Star', 'Buggles', 'QmRbNMYiaSRERRnyPyPEVdM1zvutbH64y9RYQGNPjC2ER6', 'QmTcSJfZgCnndG7r5ET9f9JiQmXp8NEeVs2vYoYmebuudy', current_time, current_time + 86400, 5*amt_1, 1).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.addProductToStore('Its Tricky', 'Run DMC', 'QmTtf5B51eRheMKpJxZXyxZ1VWBhtR29pCtdjvvYUkrLyC', 'QmWuRddiUaBo4kDxMjzLg62SXW7v81yfZQnF2AWsPqU3bP', current_time, current_time + 86400 + 86400 + 86400, 5*amt_1, 1).then(function(f) {console.log(f)})});
 EcommerceStore.deployed().then(function(i) {i.productIndex.call().then(function(f){console.log(f)})});
}
