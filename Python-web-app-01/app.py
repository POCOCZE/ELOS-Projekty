from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/kubernetes')
def kubernetes():
    return render_template('kubernetes.html')

@app.route('/docker')
def docker():
    return render_template('docker.html')

@app.route('/cloud-native')
def cloud_native():
    return render_template('cloud-native.html')