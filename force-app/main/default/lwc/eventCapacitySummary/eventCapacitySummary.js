import { LightningElement, api, wire } from 'lwc';
import getSummary from '@salesforce/apex/EventCapacitySummaryController.getSummary';

export default class EventCapacitySummary extends LightningElement {
    // Salesforce injects the current Event__c record Id when this LWC runs on a record page.
    // The Apex summary call will use this Id to calculate reserved and available seats.
    @api recordId;

    summary;
    error;
    @wire(getSummary,{eventId: '$recordId'})
    wiredSummary({data, error}) {
        if(data){
            this.summary = data;
            this.error = undefined;
        }else if(error){
            this.summary = undefined;
            this.error = error;
        }
    }

    get hasSummary(){
        return Boolean(this.summary)
    }

    get isLoading(){
        return !this.summary && !this.error;
    }

    get progressStyle(){
        const percentage = this.summary?.occupancyPercentage || 0;
        return `width: ${percentage}%;`;
    }

    get statusClass() {
        const theme = this.summary?.statusTheme || 'neutral';
        return `capacity-status capacity-status_${theme}`;
    }

    get availableSeatsLabel() {
        return this.summary?.hasCapacity ? this.summary.availableSeats : '--';
    }

    get maxCapacityLabel() {
        return this.summary?.hasCapacity ? this.summary.maxCapacity : '--';
    }
}
