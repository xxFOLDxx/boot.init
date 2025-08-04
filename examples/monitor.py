#!/usr/bin/env python3
"""
Simple System Monitor
Monitors system resources and logs alerts when thresholds are exceeded.
"""

import time
import psutil
import logging
import json
import os
from datetime import datetime

# Configuration
CONFIG = {
    "cpu_threshold": 80.0,      # CPU usage percentage
    "memory_threshold": 85.0,   # Memory usage percentage
    "disk_threshold": 90.0,     # Disk usage percentage
    "check_interval": 30,       # Check interval in seconds
    "log_file": os.path.expanduser("~/logs/system-monitor.log"),
    "alerts_file": os.path.expanduser("~/logs/system-alerts.json"),
    "network_monitor": True,    # Monitor network interfaces
    "process_monitor": True,    # Monitor top processes
}

# Setup logging
os.makedirs(os.path.dirname(CONFIG["log_file"]), exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(CONFIG["log_file"]),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

class SystemMonitor:
    def __init__(self):
        self.alerts = []
        
    def check_cpu(self):
        """Check CPU usage"""
        cpu_percent = psutil.cpu_percent(interval=1)
        if cpu_percent > CONFIG["cpu_threshold"]:
            alert = {
                "timestamp": datetime.now().isoformat(),
                "type": "cpu",
                "value": cpu_percent,
                "threshold": CONFIG["cpu_threshold"],
                "message": f"High CPU usage: {cpu_percent:.1f}%"
            }
            self.alerts.append(alert)
            logger.warning(alert["message"])
            return False
        return True
    
    def check_memory(self):
        """Check memory usage"""
        memory = psutil.virtual_memory()
        if memory.percent > CONFIG["memory_threshold"]:
            alert = {
                "timestamp": datetime.now().isoformat(),
                "type": "memory",
                "value": memory.percent,
                "threshold": CONFIG["memory_threshold"],
                "message": f"High memory usage: {memory.percent:.1f}% ({memory.used // 1024 // 1024}MB used)"
            }
            self.alerts.append(alert)
            logger.warning(alert["message"])
            return False
        return True
    
    def check_disk(self):
        """Check disk usage"""
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        if disk_percent > CONFIG["disk_threshold"]:
            alert = {
                "timestamp": datetime.now().isoformat(),
                "type": "disk",
                "value": disk_percent,
                "threshold": CONFIG["disk_threshold"],
                "message": f"High disk usage: {disk_percent:.1f}% ({disk.used // 1024 // 1024 // 1024}GB used)"
            }
            self.alerts.append(alert)
            logger.warning(alert["message"])
            return False
        return True
    
    def check_network(self):
        """Check network interfaces"""
        if not CONFIG["network_monitor"]:
            return True
            
        try:
            stats = psutil.net_io_counters(pernic=True)
            for interface, stat in stats.items():
                if interface.startswith('lo'):  # Skip loopback
                    continue
                    
                # Log network activity (optional)
                logger.debug(f"Network {interface}: {stat.bytes_sent // 1024 // 1024}MB sent, "
                           f"{stat.bytes_recv // 1024 // 1024}MB received")
            return True
        except Exception as e:
            logger.error(f"Network check failed: {e}")
            return False
    
    def check_processes(self):
        """Check top processes by CPU and memory"""
        if not CONFIG["process_monitor"]:
            return True
            
        try:
            # Get top CPU processes
            top_cpu = sorted(psutil.process_iter(['pid', 'name', 'cpu_percent']),
                           key=lambda p: p.info['cpu_percent'] or 0, reverse=True)[:5]
            
            # Get top memory processes
            top_memory = sorted(psutil.process_iter(['pid', 'name', 'memory_percent']),
                              key=lambda p: p.info['memory_percent'] or 0, reverse=True)[:5]
            
            # Log if any process is using too much CPU
            for proc in top_cpu:
                if proc.info['cpu_percent'] and proc.info['cpu_percent'] > 50:
                    logger.warning(f"High CPU process: {proc.info['name']} (PID {proc.info['pid']}) "
                                 f"using {proc.info['cpu_percent']:.1f}% CPU")
            
            return True
        except Exception as e:
            logger.error(f"Process check failed: {e}")
            return False
    
    def get_system_info(self):
        """Get current system information"""
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        info = {
            "timestamp": datetime.now().isoformat(),
            "cpu": {
                "percent": cpu_percent,
                "count": psutil.cpu_count(),
                "freq": psutil.cpu_freq()._asdict() if psutil.cpu_freq() else None
            },
            "memory": {
                "total": memory.total,
                "available": memory.available,
                "percent": memory.percent,
                "used": memory.used
            },
            "disk": {
                "total": disk.total,
                "used": disk.used,
                "free": disk.free,
                "percent": (disk.used / disk.total) * 100
            },
            "load_avg": os.getloadavg() if hasattr(os, 'getloadavg') else None,
            "uptime": time.time() - psutil.boot_time()
        }
        
        return info
    
    def save_alerts(self):
        """Save alerts to JSON file"""
        if self.alerts:
            try:
                os.makedirs(os.path.dirname(CONFIG["alerts_file"]), exist_ok=True)
                with open(CONFIG["alerts_file"], 'w') as f:
                    json.dump(self.alerts, f, indent=2)
                logger.info(f"Saved {len(self.alerts)} alerts to {CONFIG['alerts_file']}")
            except Exception as e:
                logger.error(f"Failed to save alerts: {e}")
    
    def run_once(self):
        """Run a single monitoring check"""
        logger.info("Running system check...")
        
        all_good = True
        all_good &= self.check_cpu()
        all_good &= self.check_memory()
        all_good &= self.check_disk()
        all_good &= self.check_network()
        all_good &= self.check_processes()
        
        if all_good:
            info = self.get_system_info()
            logger.info(f"System OK - CPU: {info['cpu']['percent']:.1f}%, "
                       f"Memory: {info['memory']['percent']:.1f}%, "
                       f"Disk: {info['disk']['percent']:.1f}%")
        
        return all_good
    
    def run_continuous(self):
        """Run continuous monitoring"""
        logger.info(f"Starting system monitor (checking every {CONFIG['check_interval']} seconds)")
        logger.info(f"Thresholds - CPU: {CONFIG['cpu_threshold']}%, "
                   f"Memory: {CONFIG['memory_threshold']}%, "
                   f"Disk: {CONFIG['disk_threshold']}%")
        
        try:
            while True:
                self.run_once()
                
                # Save alerts periodically
                if self.alerts:
                    self.save_alerts()
                    self.alerts = []  # Clear alerts after saving
                
                time.sleep(CONFIG["check_interval"])
                
        except KeyboardInterrupt:
            logger.info("Monitor stopped by user")
            self.save_alerts()
        except Exception as e:
            logger.error(f"Monitor error: {e}")
            self.save_alerts()

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="System Monitor")
    parser.add_argument("--once", action="store_true", help="Run once and exit")
    parser.add_argument("--config", help="Config file path")
    parser.add_argument("--cpu-threshold", type=float, help="CPU threshold percentage")
    parser.add_argument("--memory-threshold", type=float, help="Memory threshold percentage")
    parser.add_argument("--disk-threshold", type=float, help="Disk threshold percentage")
    
    args = parser.parse_args()
    
    # Update config from command line arguments
    if args.cpu_threshold:
        CONFIG["cpu_threshold"] = args.cpu_threshold
    if args.memory_threshold:
        CONFIG["memory_threshold"] = args.memory_threshold
    if args.disk_threshold:
        CONFIG["disk_threshold"] = args.disk_threshold
    
    # Load config file if provided
    if args.config and os.path.exists(args.config):
        try:
            with open(args.config, 'r') as f:
                file_config = json.load(f)
                CONFIG.update(file_config)
        except Exception as e:
            logger.error(f"Failed to load config file: {e}")
    
    monitor = SystemMonitor()
    
    if args.once:
        monitor.run_once()
    else:
        monitor.run_continuous()

if __name__ == "__main__":
    main()
