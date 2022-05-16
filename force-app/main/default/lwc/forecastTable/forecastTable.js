import { LightningElement } from 'lwc';
import { summaryYears, lineItemData, summaryMonths } from './demoContent';

export default class ForecastTable extends LightningElement {
    summaryYears = summaryYears;
    lineItemData = lineItemData;
    summaryMonths = summaryMonths;
    dataToShow = {};
    columnHeadersForMonthlyView = [];
    monthlyView = false;
    connectedCallback() {
        // console.log('sumaryYears', summaryYears);
        // console.log('lineItemData', lineItemData);
        
        // generating yearsData obj to show data in table for years
        this.dataToShow = JSON.parse(JSON.stringify(lineItemData));
        this.dataToShow.forEach(itemData => {
            // generating month values here
            itemData.startMonth = this.convertDateToShortForm(itemData.startMonth);

            itemData.yearData = [];
            this.summaryYears.responseData.yearsData.forEach(yearData => {
                yearData.lineData.forEach(lineItem => {
                    if(lineItem.recordId === itemData.productFLIId) {
                        itemData.yearData.push(lineItem.amount);
                    }
                });
            });
            
            itemData.monthData = [];
            this.summaryMonths.responseData.linesData.forEach(lineItem => {
                if(lineItem.recordId === itemData.productFLIId) {
                    if(lineItem.startYear > this.summaryMonths.responseData.startYear) {
                        for(let i = this.summaryMonths.responseData.startMonth; i <= 10 + lineItem.startYear - this.summaryMonths.responseData.startYea; i++) {
                            itemData.monthData.push('-'); 
                        }
                    }
                    else if(lineItem.startMonth > this.summaryMonths.responseData.startMonth) {
                        for(let i = this.summaryMonths.responseData.startMonth; i < lineItem.startMonth; i++) {
                            itemData.monthData.push('-'); 
                        }
                    }
                    itemData.monthData = [...itemData.monthData, ...lineItem.data];
                    if(itemData.monthData.length !== this.summaryMonths.responseData.summaryAmount.length) {
                        for(let i = itemData.monthData.length; i < this.summaryMonths.responseData.summaryAmount.length ; i++) {
                            itemData.monthData.push('-');
                        }
                    }
                }
            })
        });
        
        // generating column headers for monthly view
        const monthsArr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        let startingMonthIndex = this.summaryMonths.responseData.startMonth - 1;
        let startingYear = this.summaryMonths.responseData.startYear;
        this.summaryMonths.responseData.summaryAmount.forEach(monthlyData => {
            if(this.columnHeadersForMonthlyView.length > 0 && monthsArr[startingMonthIndex] === 'Jan') {
                startingYear++;
            }
            this.columnHeadersForMonthlyView.push(`${monthsArr[startingMonthIndex]} ${startingYear}`);
            if(startingMonthIndex === 11) {
                startingMonthIndex = 0;
            }
            else {
                startingMonthIndex++;
            }
        })
    }

    handleMenuItemSelection(event) {
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'monthlySummary') {
            this.monthlyView = !this.monthlyView;
        }
    }

    convertDateToShortForm(dateStr) {
        if(dateStr) {
            const monthsArr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            const dateArr = dateStr.split('/');
            return `${monthsArr[parseInt(dateArr[0]) - 1]} ${dateArr[2]}`;
        }
        return '';
    }
}