from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

# Temporary storage for product data
product_data = {}

@app.route('/scan_product', methods=['POST'])
def scan_product():
    barcode = request.json.get('barcode')
    response = requests.get(f'https://world.openfoodfacts.org/api/v0/product/{barcode}.json')
    if response.status_code == 200:
        global product_data
        product_data = response.json()['product']
        return jsonify({'message': 'Product data fetched successfully'}), 200
    else:
        return jsonify({'error': 'Product not found'}), 404

@app.route('/get_product_data', methods=['GET'])
def get_product_data():
    return jsonify(product_data), 200

if __name__ == '__main__':
    app.run(debug=True)
