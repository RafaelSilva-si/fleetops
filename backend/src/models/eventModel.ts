export interface EventModel {
  vehicleId: string;
  type: string;
  timestamp: string;
  details: {
    location: string;
    fuelLevel: number;
  };
}
