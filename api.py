from google.transit import gtfs_realtime_pb2
import urllib.request
from flask import Flask, jsonify

app = Flask(__name__)


@app.route('/fetchData', methods = ['GET'])
def hello():
    feed = gtfs_realtime_pb2.FeedMessage()
    response = urllib.request.urlopen('https://www.ztm.poznan.pl/pl/dla-deweloperow/getGtfsRtFile/?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ0ZXN0Mi56dG0ucG96bmFuLnBsIiwiY29kZSI6MSwibG9naW4iOiJtaFRvcm8iLCJ0aW1lc3RhbXAiOjE1MTM5NDQ4MTJ9.ND6_VN06FZxRfgVylJghAoKp4zZv6_yZVBu_1-yahlo&file=vehicle_positions.pb')
    feed.ParseFromString(response.read())
    result = []
    result = {"vehicles": []}
    for entity in feed.entity:
        if entity.HasField('vehicle'):
            result["vehicles"].append({
                "id": entity.id,
                "label": entity.vehicle.vehicle.label,
                "latitude": entity.vehicle.position.latitude,
                "longitude": entity.vehicle.position.longitude,
            })
    print(len(result["vehicles"]))
    return jsonify(result)

app.run(host='0.0.0.0', port=8000)

