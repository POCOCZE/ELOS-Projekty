import unittest
from app import app

class FlaskAppTestCase(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_index(self):
        result = self.app.get('/')
        self.assertEqual(result.status_code, 200)
        self.assertIn(b'Welcome to ELOS!', result.data)

    def test_kubernetes(self):
        result = self.app.get('/kubernetes')
        self.assertEqual(result.status_code, 200)
        self.assertIn(b'Kubernetes', result.data)

    def test_cloud_native(self):
        result = self.app.get('/cloud-native')
        self.assertEqual(result.status_code, 200)
        self.assertIn(b'Cloud-Native', result.data)

    def test_docker(self):
        result = self.app.get('/docker')
        self.assertEqual(result.status_code, 200)
        self.assertIn(b'Docker', result.data)

if __name__ == '__main__':
    unittest.main()
