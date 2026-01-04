class VRCampusEngine:
    def __init__(self):
        self.active_worlds = ["SmartClass", "BiologyLab", "AncientRome"]
    
    def connect_student(self, avatar_id, world_name):
        return {"status": "Immersive", "world": world_name, "latency": "2ms"}

