
import unittest
from backend.priority import priority_queue


class TestPriorityQueue(unittest.TestCase):

    def test_critical_priority_first(self):
        products = [
            {"product_id": 1, "priority": "LOW"},
            {"product_id": 2, "priority": "CRITICAL"},
            {"product_id": 3, "priority": "HIGH"}
        ]

        result = priority_queue(products)

        self.assertEqual(result[0]["priority"], "CRITICAL")

    def test_priority_order(self):
        products = [
            {"product_id": 1, "priority": "LOW"},
            {"product_id": 2, "priority": "HIGH"},
            {"product_id": 3, "priority": "MEDIUM"},
            {"product_id": 4, "priority": "CRITICAL"}
        ]

        result = priority_queue(products)

        expected = ["CRITICAL", "HIGH", "MEDIUM", "LOW"]

        self.assertEqual(
            [item["priority"] for item in result],
            expected
        )

    def test_same_priority_order(self):
        products = [
            {"product_id": 3, "priority": "HIGH"},
            {"product_id": 1, "priority": "HIGH"},
            {"product_id": 2, "priority": "HIGH"}
        ]

        result = priority_queue(products)

        self.assertEqual(
            [item["product_id"] for item in result],
            [1, 2, 3]
        )

    def test_empty_queue(self):
        self.assertEqual(priority_queue([]), [])


if __name__ == "__main__":
    unittest.main()
