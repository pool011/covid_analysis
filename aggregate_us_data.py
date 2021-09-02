import csv
import sys
import argparse
import datetime
#import curses

# Create cursor
#scr = curses.initscr()

class Composite_Table:
    def __init__(self, last, first = "04-12-2020", read_path = "../COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us/", verb=False):
        self.fieldnames = ['Province_State', 'Country_Region', 'Date', 'UID', 'Last_Update', 'FIPS', 'ISO3', 'Long_',  'Lat', 'Confirmed', 'Deaths', 'Recovered', 'Active','Mortality_Rate', 'People_Tested', 'Testing_Rate', 'People_Hospitalized', 'Hospitalization_Rate', 'Incident_Rate', 'Case_Fatality_Ratio', 'Total_Test_Results', 'Cases_28_Days', 'Deaths_28_Days']
        self.read_file_names = self.make_file_names(last, first)
        self.data = {}
        self.dates = []

        for file_name in self.read_file_names:
            read_file_path = f"{read_path}{file_name}"
            table_data = Table(read_file_path, verb=verb)

            if verb:
                print("Adding to data...")
            self.data[table_data.date_str] = table_data
        if verb:
            print("\nData:")
            print(self.data, "\n")
        else: 
            print("Aggregated")

    def make_file_names(self, last, first):
        print("Generating file names...")
        start = datetime.datetime.strptime(first, "%m-%d-%Y")
        #print(start)
        
        end = datetime.datetime.strptime(last, '%m-%d-%Y') + datetime.timedelta(days=1)

        self.dates = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]

        file_names = []
        for date in self.dates:
            file_names.append(date.strftime("%m-%d-%Y.csv"))
        return file_names

    def write_to_csv(self, write_file, verb):
        with open(write_file, mode = 'w', newline = '') as outfile:
            if verb: 
                print(f"Generating headers for {write_file}...")

            writer = csv.DictWriter(outfile, fieldnames=self.fieldnames)
            writer.writeheader()
            
            if verb: 
                print(f"Writing contents to {write_file}...")
            for date in self.data.keys():
                writer.writerows(self.data[date].rows)
        if verb:
            print(f"Data aggregated to {write_file}")


class Table:
    def __init__(self, read_file, verb):

        self.rows = []

        date_str = read_file[-14:-4]
        self.date = datetime.datetime.strptime(date_str, "%m-%d-%Y")
        self.date_str = self.date.strftime("%Y-%m-%d")

        with open(read_file, mode = 'r') as infile:
            if verb:
                print(f"Generating reader for {read_file}...")
            reader = csv.DictReader(infile)
            if verb:
                print(f"Sorting file contents...")
            for row in reader:
                row['Date'] = self.date_str
                if row['Country_Region'] == 'US':
                    self.rows.append(row)

        self.rows.sort(key = lambda x: x['Province_State'])

def parse_args(arg_list):
    """Parses arguments from the command line.

    Args:
        arg_list (list): a list of arguments from the command line, usually sys.argv[1:].

    Returns:
        args (obj): contains the variables passed from the command line as attributes of args.

    """
    parser = argparse.ArgumentParser(description = "Parses file path argument")
    parser.add_argument('last', type = str, help = 'most recent date available')
    parser.add_argument('-v', '--verbose', action = 'store_true', help = 'Increase verbosity of output')
    args = parser.parse_args(arg_list)
    return args


def main(last, verb):
    aggr_data_us = Composite_Table(last, verb=verb)
    aggr_data_us.write_to_csv("daily_updates_ts_us.csv", verb)


if __name__ == '__main__':
    args = parse_args(sys.argv[1:])
    #print(f"Total Arguments Passed: {len(sys.argv)}\nlast: {args.last}")
    # if args.last == None:
    #     today = datetime.date.today()
    #     main(today)
    main(args.last, args.verbose)
